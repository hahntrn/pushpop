import Foundation
import AppKit

struct StackItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var text: String
}

struct CompletedTask: Identifiable, Codable, Hashable {
    var id = UUID()
    var text: String
    var completedAt: Date
}

/// Index 0 is the top of the stack, so push/pop/peek and drag-to-reorder all
/// agree on which end is "top".
@MainActor
final class StackStore: ObservableObject {
    @Published private(set) var stack: [StackItem] = []
    @Published private(set) var history: [CompletedTask] = []
    /// Surfaced in the UI so a failed load or save is never silent.
    @Published private(set) var problem: String?

    private struct Storage: Codable {
        var stack: [StackItem]
        var history: [CompletedTask]
    }

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            let dir = support.appendingPathComponent("pushpop", isDirectory: true)
            self.fileURL = dir.appendingPathComponent("stack.json")
        }
        load()
    }

    var top: StackItem? { stack.first }

    /// Previews get a throwaway file so they never touch the real saved stack.
    static func preview(_ tasks: [String] = ["ship the release", "debug the sql", "call the bank"]) -> StackStore {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("pushpop-preview-\(UUID().uuidString).json")
        let store = StackStore(fileURL: url)
        for task in tasks.reversed() { store.push(task) }
        return store
    }

    // MARK: Stack Operations

    func push(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        stack.insert(StackItem(text: trimmed), at: 0)
        save()
    }

    @discardableResult
    func pop() -> CompletedTask? {
        guard !stack.isEmpty else { return nil }
        let task = stack.removeFirst()
        let done = CompletedTask(text: task.text, completedAt: Date())
        history.insert(done, at: 0)
        NSSound(named: "Pop")?.play()
        save()
        return done
    }

    func moveToTop(_ id: StackItem.ID) {
        guard let i = stack.firstIndex(where: { $0.id == id }), i != 0 else { return }
        stack.insert(stack.remove(at: i), at: 0)
        save()
    }

    /// Offsets must index `stack` directly; callers must not pass offsets from a
    /// filtered view, or unrelated items get permuted.
    func reorder(from source: IndexSet, to destination: Int) {
        stack.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func search(_ text: String) -> [StackItem] {
        stack.filter { $0.text.localizedCaseInsensitiveContains(text) }
    }

    // MARK: Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(Storage(stack: stack, history: history))
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
            problem = nil
        } catch {
            problem = "Couldn’t save: \(error.localizedDescription)"
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }  // absent file = first run
        do {
            let stored = try JSONDecoder().decode(Storage.self, from: data)
            stack = stored.stack
            history = stored.history
        } catch {
            // Never overwrite data we failed to read - set it aside first.
            let backup = fileURL.appendingPathExtension("corrupt")
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.moveItem(at: fileURL, to: backup)
            problem = "Saved stack was unreadable; kept a copy at \(backup.lastPathComponent)"
        }
    }
}
