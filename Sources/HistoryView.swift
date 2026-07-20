import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: StackStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.history.isEmpty {
                    ContentUnavailableView("Nothing completed yet", systemImage: "checkmark.circle")
                } else {
                    List(store.history) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.text)
                            Text(item.completedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 420)
    }
}

#Preview {
    let store = StackStore.preview()
    store.pop()
    return HistoryView().environmentObject(store)
}
