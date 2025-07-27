import SwiftUI

struct PeekView: View {
    @EnvironmentObject var store: StackStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTasks.indices, id: \.self) { index in
                    Text(filteredTasks[index])
                }
                .onMove(perform: move)
            }
            .searchable(text: $searchText)
            .navigationTitle("Stack")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }

    private var filteredTasks: [String] {
        if searchText.isEmpty { return store.peekAll() }
        return store.search(searchText)
    }

    private func move(from source: IndexSet, to destination: Int) {
        store.reorder(from: source, to: destination)
    }
}

#Preview {
    PeekView().environmentObject(StackStore())
}
