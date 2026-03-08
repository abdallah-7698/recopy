import Testing
import AppKit
import Carbon
@testable import Recopy

@Suite("ShortcutConfig Tests")
struct ShortcutConfigTests {

    @Test("Default shortcut is Cmd+Ctrl+X")
    func defaultShortcut() {
        let config = ShortcutConfig.default
        #expect(config.keyCode == UInt16(kVK_ANSI_X))
        #expect(config.modifiers.contains(.command))
        #expect(config.modifiers.contains(.control))
    }

    @Test("Display string contains modifier symbols")
    func displayString() {
        let config = ShortcutConfig.default
        let display = config.displayString
        #expect(display.contains("⌘"))
        #expect(display.contains("⌃"))
    }

    @Test("Carbon modifiers are correctly mapped")
    func carbonModifiers() {
        let config = ShortcutConfig(
            keyCode: 0,
            modifiers: [.command, .control, .option, .shift]
        )
        let carbon = config.carbonModifiers
        #expect(carbon & UInt32(cmdKey) != 0)
        #expect(carbon & UInt32(controlKey) != 0)
        #expect(carbon & UInt32(optionKey) != 0)
        #expect(carbon & UInt32(shiftKey) != 0)
    }

    @Test("Save and load roundtrip preserves shortcut")
    func saveLoadRoundtrip() {
        let original = ShortcutConfig(
            keyCode: 12,
            modifiers: [.command, .option]
        )
        original.save()

        let loaded = ShortcutConfig.load()
        #expect(loaded.keyCode == original.keyCode)
        #expect(loaded.modifiers == original.modifiers)

        // Restore default to not pollute other tests
        ShortcutConfig.default.save()
    }

    @Test("Equality works correctly")
    func equality() {
        let a = ShortcutConfig(keyCode: 7, modifiers: [.command, .control])
        let b = ShortcutConfig(keyCode: 7, modifiers: [.command, .control])
        let c = ShortcutConfig(keyCode: 8, modifiers: [.command, .control])

        #expect(a == b)
        #expect(a != c)
    }
}
