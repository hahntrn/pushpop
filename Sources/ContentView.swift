import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StackStore
    @State private var newTask: String = ""

    var body: some View {
        VStack {
            HStack {
                TextField("New Task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel(Text("Task field"))
                Button("Push") { push() }
                    .keyboardShortcut("p", modifiers: .command)
                    .accessibilityLabel(Text("Push task"))
                Button("Pop") { store.pop() }
                    .keyboardShortcut("o", modifiers: .command)
                    .accessibilityLabel(Text("Pop task"))
            }
            if let top = store.peekAll().last {
                Text(top)
                    .font(.title2)
                    .padding()
            } else {
                Text("Stack is empty")
                    .padding()
            }
            HStack {
                Button("Peek") { showingPeek.toggle() }
                    .keyboardShortcut("k", modifiers: .command)
                Button("History") { showingHistory.toggle() }
                    .keyboardShortcut("h", modifiers: .command)
            }
        }
        .padding()
        .sheet(isPresented: $showingPeek) {
            PeekView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(store)
        }
        .frame(minWidth: 300)
    }

    @State private var showingPeek = false
    @State private var showingHistory = false

    private func push() {
        guard !newTask.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.push(newTask)
        newTask = ""
    }
}

#Preview {
    ContentView().environmentObject(StackStore())
}
