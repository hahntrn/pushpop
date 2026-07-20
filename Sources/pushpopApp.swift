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
        .defaultSize(width: 400, height: 220)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    /// Resolved on demand: the SwiftUI window does not reliably exist yet when
    /// the status item is built, and holding a stale reference breaks toggling.
    private var mainWindow: NSWindow? {
        NSApp.windows.first { $0.canBecomeMain && !($0 is NSPanel) }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = mainWindow {
            window.isReleasedWhenClosed = false
            window.level = .floating  // macOS 14 has no SwiftUI .windowLevel modifier
            window.orderFrontRegardless()
        }
        setupStatusItem()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false  // closing the window leaves the menu bar item to bring it back
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "arrow.up.arrow.down.circle",
                               accessibilityDescription: "pushpop")
        button.action = #selector(toggleWindow)
        button.target = self
    }

    @objc func toggleWindow() {
        guard let window = mainWindow else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
