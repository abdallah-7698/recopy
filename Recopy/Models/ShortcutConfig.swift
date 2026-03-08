import AppKit
import Carbon

struct ShortcutConfig: Equatable {
    var keyCode: UInt16
    var modifiers: NSEvent.ModifierFlags

    static let `default` = ShortcutConfig(
        keyCode: UInt16(kVK_ANSI_X),
        modifiers: [.command, .control]
    )

    // MARK: - UserDefaults

    private static let keyCodeKey = "shortcut_keyCode"
    private static let modifiersKey = "shortcut_modifiers"

    static func load() -> ShortcutConfig {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: keyCodeKey) != nil else { return .default }
        let keyCode = UInt16(defaults.integer(forKey: keyCodeKey))
        let rawMods = UInt(defaults.integer(forKey: modifiersKey))
        return ShortcutConfig(keyCode: keyCode, modifiers: NSEvent.ModifierFlags(rawValue: rawMods))
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(Int(keyCode), forKey: ShortcutConfig.keyCodeKey)
        defaults.set(Int(modifiers.rawValue), forKey: ShortcutConfig.modifiersKey)
    }

    // MARK: - Display

    var displayString: String {
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        parts.append(keyName)
        return parts.joined()
    }

    var keyName: String {
        let specialKeys: [UInt16: String] = [
            UInt16(kVK_Return): "↩",
            UInt16(kVK_Tab): "⇥",
            UInt16(kVK_Space): "Space",
            UInt16(kVK_Delete): "⌫",
            UInt16(kVK_Escape): "⎋",
            UInt16(kVK_ForwardDelete): "⌦",
            UInt16(kVK_UpArrow): "↑",
            UInt16(kVK_DownArrow): "↓",
            UInt16(kVK_LeftArrow): "←",
            UInt16(kVK_RightArrow): "→",
            UInt16(kVK_F1): "F1", UInt16(kVK_F2): "F2",
            UInt16(kVK_F3): "F3", UInt16(kVK_F4): "F4",
            UInt16(kVK_F5): "F5", UInt16(kVK_F6): "F6",
            UInt16(kVK_F7): "F7", UInt16(kVK_F8): "F8",
            UInt16(kVK_F9): "F9", UInt16(kVK_F10): "F10",
            UInt16(kVK_F11): "F11", UInt16(kVK_F12): "F12",
        ]

        if let special = specialKeys[keyCode] { return special }

        let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let layoutPtr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        guard let layoutData = layoutPtr else {
            return String(format: "0x%02X", keyCode)
        }
        let data = Unmanaged<CFData>.fromOpaque(layoutData).takeUnretainedValue() as Data
        return data.withUnsafeBytes { rawBuf -> String in
            guard let ptr = rawBuf.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else {
                return String(format: "0x%02X", keyCode)
            }
            var deadKeyState: UInt32 = 0
            var length = 0
            var chars = [UniChar](repeating: 0, count: 4)
            let status = UCKeyTranslate(
                ptr,
                keyCode,
                UInt16(kUCKeyActionDisplay),
                0,
                UInt32(LMGetKbdType()),
                UInt32(kUCKeyTranslateNoDeadKeysBit),
                &deadKeyState,
                4,
                &length,
                &chars
            )
            guard status == noErr, length > 0 else {
                return String(format: "0x%02X", keyCode)
            }
            return String(utf16CodeUnits: chars, count: length).uppercased()
        }
    }

    // MARK: - Carbon Modifiers

    var carbonModifiers: UInt32 {
        var mods: UInt32 = 0
        if modifiers.contains(.command) { mods |= UInt32(cmdKey) }
        if modifiers.contains(.control) { mods |= UInt32(controlKey) }
        if modifiers.contains(.option) { mods |= UInt32(optionKey) }
        if modifiers.contains(.shift) { mods |= UInt32(shiftKey) }
        return mods
    }
}
