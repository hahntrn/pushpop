import SwiftUI

struct PeekView: View {
    @EnvironmentObject var store: StackStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var showingHistory = false

    private var isFiltering: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var tasks: [StackItem] {
        isFiltering ? store.search(searchText) : store.stack
    }

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        isFiltering ? "No matches" : "Stack is empty",
                        systemImage: isFiltering ? "magnifyingglass" : "tray")
                } else if isFiltering {
                    // Drag is disabled while filtering: row offsets index the
                    // filtered array, and applying them to the full stack would
                    // silently reorder items the user never touched.
                    List(tasks) { task in
                        row(task)
                    }
                } else {
                    List {
                        ForEach(tasks) { task in
                            row(task)
                        }
                        .onMove { store.reorder(from: $0, to: $1) }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search the stack")
            .navigationTitle("Stack")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("History…") { showingHistory = true }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 420)
        .sheet(isPresented: $showingHistory) {
            HistoryView().environmentObject(store)
        }
    }

    @ViewBuilder
    private func row(_ task: StackItem) -> some View {
        let isTop = task.id == store.top?.id
        HStack {
            Text(task.text)
                .fontWeight(isTop ? .semibold : .regular)
            if isTop {
                Text("top")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.tint, in: Capsule())
                    .foregroundStyle(.white)
            }
            Spacer()
            if !isTop {
                Button("Move to top") { store.moveToTop(task.id) }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(Text("Move \(task.text) to top of stack"))
            }
        }
    }
}

#Preview {
    PeekView().environmentObject(StackStore.preview())
}
