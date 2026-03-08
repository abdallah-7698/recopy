import Carbon
import AppKit
import ApplicationServices

class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var eventHandlerRef: EventHandlerRef?
    private(set) var shortcut: ShortcutConfig

    var onToggle: (() -> Void)?

    init() {
        shortcut = ShortcutConfig.load()
    }

    // MARK: - Public

    func register() {
        requestAccessibility()
        registerNSEventMonitors()
        installCarbonHandler()
        registerCarbonHotkey()
    }

    func updateShortcut(_ newShortcut: ShortcutConfig) {
        shortcut = newShortcut
        shortcut.save()
        unregisterCarbonHotkey()
        removeNSEventMonitors()
        registerNSEventMonitors()
        registerCarbonHotkey()
    }

    // MARK: - Accessibility

    private func requestAccessibility() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(opts) {
            print("Accessibility permission required for global hotkeys.")
        }
    }

    // MARK: - NSEvent Monitors

    private func registerNSEventMonitors() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true { return nil }
            return event
        }
    }

    private func removeNSEventMonitors() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard event.keyCode == shortcut.keyCode, flags == shortcut.modifiers else {
            return false
        }
        DispatchQueue.main.async { [weak self] in
            self?.onToggle?()
        }
        return true
    }

    // MARK: - Carbon Hotkey

    private func installCarbonHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let ptr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, inEvent, userData -> OSStatus in
                guard let userData, let inEvent else {
                    return OSStatus(eventNotHandledErr)
                }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()

                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    inEvent,
                    UInt32(kEventParamDirectObject),
                    UInt32(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard status == noErr, hotKeyID.id == 1 else {
                    return OSStatus(eventNotHandledErr)
                }

                DispatchQueue.main.async { manager.onToggle?() }
                return noErr
            },
            1, &eventType, ptr, &eventHandlerRef
        )
    }

    private func registerCarbonHotkey() {
        let signature = OSType(0x52435059) // "RCPY"
        let hotKeyID = EventHotKeyID(signature: signature, id: 1)
        RegisterEventHotKey(
            UInt32(shortcut.keyCode),
            shortcut.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregisterCarbonHotkey() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }
}
