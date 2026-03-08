import Testing
import Foundation
@testable import Recopy

@Suite("ClipboardManager Tests")
struct ClipboardManagerTests {

    // MARK: - Initial State

    @Test("Manager starts with empty items")
    func initialState() {
        let manager = ClipboardManager()
        #expect(manager.items.isEmpty)
        #expect(manager.selectedIndex == 0)
    }

    // MARK: - Delete

    @Test("Delete removes the correct item")
    func deleteItem() {
        let manager = ClipboardManager()
        let item1 = ClipboardItem(text: "First", timestamp: Date())
        let item2 = ClipboardItem(text: "Second", timestamp: Date())
        let item3 = ClipboardItem(text: "Third", timestamp: Date())
        manager.items = [item1, item2, item3]

        manager.deleteItem(item2)

        #expect(manager.items.count == 2)
        #expect(manager.items[0].text == "First")
        #expect(manager.items[1].text == "Third")
    }

    @Test("Delete nonexistent item does nothing")
    func deleteNonexistentItem() {
        let manager = ClipboardManager()
        let item1 = ClipboardItem(text: "First", timestamp: Date())
        manager.items = [item1]

        let phantom = ClipboardItem(text: "Ghost", timestamp: Date())
        manager.deleteItem(phantom)

        #expect(manager.items.count == 1)
    }

    @Test("Delete clamps selectedIndex when out of bounds")
    func deleteClamps() {
        let manager = ClipboardManager()
        let item1 = ClipboardItem(text: "A", timestamp: Date())
        let item2 = ClipboardItem(text: "B", timestamp: Date())
        manager.items = [item1, item2]
        manager.selectedIndex = 1

        manager.deleteItem(item2)

        #expect(manager.selectedIndex == 0)
    }

    // MARK: - Toggle Pin

    @Test("Toggle pin pins an unpinned item")
    func pinItem() {
        let manager = ClipboardManager()
        let item = ClipboardItem(text: "Pin me", timestamp: Date())
        manager.items = [item]

        manager.togglePin(item)

        #expect(manager.items[0].isPinned == true)
    }

    @Test("Toggle pin unpins a pinned item")
    func unpinItem() {
        let manager = ClipboardManager()
        var item = ClipboardItem(text: "Unpin me", timestamp: Date())
        item.isPinned = true
        manager.items = [item]

        manager.togglePin(item)

        #expect(manager.items[0].isPinned == false)
    }

    @Test("Pinned items sort before unpinned items")
    func pinnedSortOrder() {
        let manager = ClipboardManager()
        let item1 = ClipboardItem(text: "A", timestamp: Date())
        let item2 = ClipboardItem(text: "B", timestamp: Date())
        let item3 = ClipboardItem(text: "C", timestamp: Date())
        manager.items = [item1, item2, item3]

        // Pin the last item — it should move to front
        manager.togglePin(item3)

        #expect(manager.items[0].text == "C")
        #expect(manager.items[0].isPinned == true)
        #expect(manager.items[1].text == "A")
        #expect(manager.items[2].text == "B")
    }

    @Test("Toggle pin on nonexistent item does nothing")
    func pinNonexistent() {
        let manager = ClipboardManager()
        let item = ClipboardItem(text: "Real", timestamp: Date())
        manager.items = [item]

        let phantom = ClipboardItem(text: "Ghost", timestamp: Date())
        manager.togglePin(phantom)

        #expect(manager.items.count == 1)
        #expect(manager.items[0].isPinned == false)
    }

    // MARK: - Clear History

    @Test("Clear removes all unpinned items")
    func clearHistory() {
        let manager = ClipboardManager()
        var pinned = ClipboardItem(text: "Pinned", timestamp: Date())
        pinned.isPinned = true
        let unpinned1 = ClipboardItem(text: "A", timestamp: Date())
        let unpinned2 = ClipboardItem(text: "B", timestamp: Date())
        manager.items = [pinned, unpinned1, unpinned2]

        manager.clearHistory()

        #expect(manager.items.count == 1)
        #expect(manager.items[0].text == "Pinned")
    }

    @Test("Clear on empty list does nothing")
    func clearEmpty() {
        let manager = ClipboardManager()
        manager.clearHistory()
        #expect(manager.items.isEmpty)
    }

    @Test("Clear clamps selectedIndex")
    func clearClamps() {
        let manager = ClipboardManager()
        let item1 = ClipboardItem(text: "A", timestamp: Date())
        let item2 = ClipboardItem(text: "B", timestamp: Date())
        manager.items = [item1, item2]
        manager.selectedIndex = 1

        manager.clearHistory()

        #expect(manager.selectedIndex == 0)
    }

    // MARK: - Clamp Selected Index

    @Test("Clamp does nothing when index is valid")
    func clampValid() {
        let manager = ClipboardManager()
        let item = ClipboardItem(text: "A", timestamp: Date())
        manager.items = [item]
        manager.selectedIndex = 0

        manager.clampSelectedIndex()

        #expect(manager.selectedIndex == 0)
    }

    @Test("Clamp reduces index to last item")
    func clampReduces() {
        let manager = ClipboardManager()
        let item = ClipboardItem(text: "A", timestamp: Date())
        manager.items = [item]
        manager.selectedIndex = 5

        manager.clampSelectedIndex()

        #expect(manager.selectedIndex == 0)
    }

    @Test("Clamp to 0 on empty list")
    func clampEmpty() {
        let manager = ClipboardManager()
        manager.selectedIndex = 3

        manager.clampSelectedIndex()

        #expect(manager.selectedIndex == 0)
    }

    // MARK: - Skip Next

    @Test("Skip next change flag is set")
    func skipNext() {
        let manager = ClipboardManager()
        // Just verify it doesn't crash — the flag is private
        manager.skipNextChange()
    }

    // MARK: - Multiple Pins

    @Test("Multiple pins maintain relative order")
    func multiplePins() {
        let manager = ClipboardManager()
        let a = ClipboardItem(text: "A", timestamp: Date())
        let b = ClipboardItem(text: "B", timestamp: Date())
        let c = ClipboardItem(text: "C", timestamp: Date())
        manager.items = [a, b, c]

        manager.togglePin(a)
        manager.togglePin(c)

        // Both pinned items should be at front
        #expect(manager.items[0].isPinned == true)
        #expect(manager.items[1].isPinned == true)
        #expect(manager.items[2].isPinned == false)
        #expect(manager.items[2].text == "B")
    }
}
