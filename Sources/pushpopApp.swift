import SwiftUI
import AppKit

@main
struct pushpopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = StackStore()

    var body: some Scene {
        WindowGroup("pushpop", id: "main") {
            ContentView()
                .environmentObject(store)
        }
        .windowStyle(.utility)
        .windowLevel(.floating)
        .defaultSize(width: 400, height: 200)
        .commands {
            CommandMenu("Window") {
                Button("Toggle Window") { appDelegate.toggleWindow() }
                    .keyboardShortcut("t")
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            self.window = window
            window.isReleasedWhenClosed = false
            window.orderFrontRegardless()
        }
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "arrow.up.arrow.down.circle", accessibilityDescription: "pushpop")
            button.action = #selector(toggleWindow)
            button.target = self
        }
    }

    @objc func toggleWindow() {
        guard let window = window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
