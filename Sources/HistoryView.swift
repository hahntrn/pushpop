import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: StackStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(store.history, id: \.0) { item in
                VStack(alignment: .leading) {
                    Text(item.0)
                    Text(item.1.formatted())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("History")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

#Preview {
    HistoryView().environmentObject(StackStore())
}
