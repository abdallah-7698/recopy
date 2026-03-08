import AppKit

class PasteService {
    private var previousApp: NSRunningApplication?

    // MARK: - Active App Tracking

    func startTrackingActiveApp() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppChanged(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }

    @objc private func activeAppChanged(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication,
              app.bundleIdentifier != Bundle.main.bundleIdentifier
        else { return }
        previousApp = app
    }

    // MARK: - Paste

    func paste(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        activatePreviousAppAndPaste()
    }

    private func activatePreviousAppAndPaste() {
        guard let app = previousApp else { return }
        app.activate()
        waitForAppThenPaste(app: app, attemptsLeft: 20)
    }

    private func waitForAppThenPaste(app: NSRunningApplication, attemptsLeft: Int) {
        if app.isActive || attemptsLeft <= 0 {
            simulateCmdV()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.waitForAppThenPaste(app: app, attemptsLeft: attemptsLeft - 1)
            }
        }
    }

    private func simulateCmdV() {
        let source = CGEventSource(stateID: .hidSystemState)
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        else { return }
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
