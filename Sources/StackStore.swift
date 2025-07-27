import Foundation
import AVFoundation

final class StackStore: ObservableObject {
    @Published private(set) var stack: [String] = []
    @Published private(set) var history: [(String, Date)] = []

    private let fileURL: URL
    private let historyURL: URL
    private var player: AVAudioPlayer?

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("pushpop", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("stack.json")
        historyURL = dir.appendingPathComponent("history.json")
        load()
    }

    // MARK: Stack Operations
    func push(_ task: String) {
        stack.append(task)
        save()
    }

    @discardableResult
    func pop() -> String? {
        guard let task = stack.popLast() else { return nil }
        history.append((task, Date()))
        playPopSound()
        save()
        return task
    }

    func peekAll() -> [String] { stack }

    func reorder(from source: IndexSet, to destination: Int) {
        stack.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func search(_ text: String) -> [String] {
        stack.filter { $0.localizedCaseInsensitiveContains(text) }
    }

    // MARK: Persistence
    private func save() {
        let data = try? JSONEncoder().encode(stack)
        try? data?.write(to: fileURL)

        let historyData = try? JSONEncoder().encode(history.map { [$0.0, ISO8601DateFormatter().string(from: $0.1)] })
        try? historyData?.write(to: historyURL)
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            stack = decoded
        }
        if let data = try? Data(contentsOf: historyURL),
           let decoded = try? JSONDecoder().decode([[String]].self, from: data) {
            history = decoded.compactMap { arr in
                if arr.count == 2, let date = ISO8601DateFormatter().date(from: arr[1]) { return (arr[0], date) }
                return nil
            }
        }
    }

    // MARK: Sound
    private func playPopSound() {
        guard let url = Bundle.main.url(forResource: "pop", withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
