import SwiftUI

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var selectedIndex: Int = 0

    private var timer: Timer?
    private var lastChangeCount = 0
    private var shouldSkipNext = false
    private let maxItems = 50

    // MARK: - Monitoring

    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func skipNextChange() {
        shouldSkipNext = true
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if shouldSkipNext {
            shouldSkipNext = false
            return
        }

        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        guard items.first(where: { !$0.isPinned })?.text != text else { return }

        let item = ClipboardItem(text: text, timestamp: Date())
        items.insert(item, at: pinnedCount)
        trimIfNeeded()
    }

    // MARK: - Actions

    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        clampSelectedIndex()
    }

    func togglePin(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPinned.toggle()
        items = items.filter(\.isPinned) + items.filter { !$0.isPinned }
    }

    func clearHistory() {
        items.removeAll { !$0.isPinned }
        clampSelectedIndex()
    }

    func clampSelectedIndex() {
        let maxIndex = max(items.count - 1, 0)
        if selectedIndex > maxIndex {
            selectedIndex = maxIndex
        }
    }

    // MARK: - Private

    private var pinnedCount: Int {
        items.filter(\.isPinned).count
    }

    private func trimIfNeeded() {
        let unpinned = items.filter { !$0.isPinned }
        if unpinned.count > maxItems,
           let oldest = unpinned.last,
           let index = items.firstIndex(of: oldest) {
            items.remove(at: index)
        }
    }
}
