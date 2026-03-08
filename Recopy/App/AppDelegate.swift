import SwiftUI
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel?
    private var shortcutPanel: NSPanel?
    private var statusItem: NSStatusItem?
    let clipboardManager = ClipboardManager()
    let hotkeyManager = HotkeyManager()
    private let pasteService = PasteService()
    private var launchAtLoginItem: NSMenuItem?
    private var showHistoryItem: NSMenuItem?

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()
        setupHotkeys()
        clipboardManager.startMonitoring()
        pasteService.startTrackingActiveApp()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "clipboard",
                accessibilityDescription: "Recopy"
            )
        }

        let menu = NSMenu()

        let historyItem = NSMenuItem(
            title: "Show History (\(hotkeyManager.shortcut.displayString))",
            action: #selector(togglePanel),
            keyEquivalent: ""
        )
        showHistoryItem = historyItem
        menu.addItem(historyItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Change Shortcut...",
            action: #selector(showShortcutRecorder),
            keyEquivalent: ""
        ))

        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        launchAtLoginItem = loginItem
        menu.addItem(loginItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Clear History",
            action: #selector(clearHistory),
            keyEquivalent: ""
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))
        statusItem?.menu = menu
    }

    // MARK: - Hotkeys

    private func setupHotkeys() {
        hotkeyManager.onToggle = { [weak self] in
            self?.togglePanel()
        }
        hotkeyManager.register()
    }

    // MARK: - Panel

    @objc func togglePanel() {
        if let panel, panel.isVisible {
            panel.orderOut(nil)
            return
        }
        showPanel()
    }

    private func showPanel() {
        let contentView = ClipboardHistoryView(
            clipboardManager: clipboardManager,
            shortcutDisplay: hotkeyManager.shortcut.displayString,
            onPaste: { [weak self] text in self?.pasteItem(text) },
            onDismiss: { [weak self] in self?.panel?.orderOut(nil) }
        )

        if panel == nil {
            panel = FloatingPanel()
        }

        panel?.contentView = NSHostingView(rootView: contentView)
        positionPanelNearMouse()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func positionPanelNearMouse() {
        guard let panel else { return }

        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first {
            NSMouseInRect(mouseLocation, $0.frame, false)
        } ?? NSScreen.main
        guard let screenFrame = screen?.visibleFrame else { return }

        let size = CGSize(width: 360, height: 500)
        var origin = CGPoint(
            x: mouseLocation.x - size.width / 2,
            y: mouseLocation.y - size.height / 2
        )

        origin.x = max(screenFrame.minX, min(origin.x, screenFrame.maxX - size.width))
        origin.y = max(screenFrame.minY, min(origin.y, screenFrame.maxY - size.height))

        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    // MARK: - Paste

    func pasteItem(_ text: String) {
        panel?.orderOut(nil)
        clipboardManager.skipNextChange()
        pasteService.paste(text)
    }

    // MARK: - Shortcut Recorder

    @objc private func showShortcutRecorder() {
        if let existing = shortcutPanel, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let recorderView = ShortcutRecorderView(
            currentShortcut: Binding(
                get: { [weak self] in self?.hotkeyManager.shortcut ?? .default },
                set: { _ in }
            ),
            onRecord: { [weak self] newShortcut in
                self?.hotkeyManager.updateShortcut(newShortcut)
                self?.showHistoryItem?.title = "Show History (\(newShortcut.displayString))"
            }
        )

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Recopy Shortcut"
        panel.contentView = NSHostingView(rootView: recorderView)
        panel.center()
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        shortcutPanel = panel
    }

    // MARK: - Menu Actions

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                launchAtLoginItem?.state = .off
            } else {
                try SMAppService.mainApp.register()
                launchAtLoginItem?.state = .on
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }

    @objc private func clearHistory() {
        clipboardManager.clearHistory()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
