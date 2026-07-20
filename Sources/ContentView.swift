import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StackStore
    @State private var newTask: String = ""
    @State private var showingPeek = false
    @State private var showingHistory = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("New task", text: $newTask)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(push)
                    .accessibilityLabel(Text("Task field"))
                Button("Push", action: push)
                    .disabled(newTask.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel(Text("Push task"))
                Button("Pop") { store.pop() }
                    .disabled(store.stack.isEmpty)
                    .keyboardShortcut(.delete, modifiers: .command)
                    .accessibilityLabel(Text("Pop task"))
            }

            if let top = store.top {
                Text(top.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(Text("Top of stack: \(top.text)"))
            } else {
                Text("Stack is empty")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            if let problem = store.problem {
                Text(problem)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Button("Peek…") { showingPeek = true }
                    .keyboardShortcut("e", modifiers: .command)
                Button("History…") { showingHistory = true }
                    .keyboardShortcut("y", modifiers: .command)
                Spacer()
                Text("\(store.stack.count) on stack")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(minWidth: 340)
        .sheet(isPresented: $showingPeek) {
            PeekView().environmentObject(store)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView().environmentObject(store)
        }
    }

    private func push() {
        store.push(newTask)
        newTask = ""
    }
}

#Preview {
    ContentView().environmentObject(StackStore.preview())
}
