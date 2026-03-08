import Testing
import Foundation
@testable import Recopy

@Suite("ClipboardItem Tests")
struct ClipboardItemTests {

    @Test("Item stores text and timestamp")
    func itemCreation() {
        let now = Date()
        let item = ClipboardItem(text: "Hello", timestamp: now)

        #expect(item.text == "Hello")
        #expect(item.timestamp == now)
        #expect(item.isPinned == false)
    }

    @Test("Each item gets a unique ID")
    func uniqueIDs() {
        let item1 = ClipboardItem(text: "A", timestamp: Date())
        let item2 = ClipboardItem(text: "A", timestamp: Date())

        #expect(item1.id != item2.id)
    }

    @Test("Items with same text but different IDs are not equal")
    func equalityRequiresID() {
        let item1 = ClipboardItem(text: "Same", timestamp: Date())
        let item2 = ClipboardItem(text: "Same", timestamp: Date())

        #expect(item1 != item2)
    }

    @Test("Item can be pinned")
    func pinning() {
        var item = ClipboardItem(text: "Pin me", timestamp: Date())
        #expect(item.isPinned == false)

        item.isPinned = true
        #expect(item.isPinned == true)
    }
}
