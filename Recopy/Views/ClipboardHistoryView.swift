import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    var shortcutDisplay: String
    var onPaste: (String) -> Void
    var onDismiss: () -> Void
    @State private var searchText = ""

    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty { return clipboardManager.items }
        return clipboardManager.items.filter {
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            SearchBar(text: $searchText)
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            itemsSection
            footerSection
        }
        .frame(width: 360, height: 500)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.7))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
        .keyboardShortcuts(
            selectedIndex: $clipboardManager.selectedIndex,
            itemCount: filteredItems.count,
            onPaste: {
                if let item = filteredItems[safe: clipboardManager.selectedIndex] {
                    onPaste(item.text)
                }
            },
            onDismiss: onDismiss
        )
        .onChange(of: searchText) { _, _ in clipboardManager.selectedIndex = 0 }
        .onAppear { clipboardManager.selectedIndex = 0 }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 15))
                .foregroundStyle(.primary.opacity(0.8))
            Text("Recopy")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.85))
            Spacer()
            ItemCountBadge(count: clipboardManager.items.count)
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Items

    @ViewBuilder
    private var itemsSection: some View {
        if filteredItems.isEmpty {
            EmptyStateView(hasSearchText: !searchText.isEmpty)
        } else {
            itemsList
        }
    }

    private var itemsList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(
                        Array(filteredItems.enumerated()),
                        id: \.element.id
                    ) { index, item in
                        ClipboardItemRow(
                            item: item,
                            isSelected: index == clipboardManager.selectedIndex,
                            onPaste: { onPaste(item.text) },
                            onDelete: { clipboardManager.deleteItem(item) },
                            onPin: { clipboardManager.togglePin(item) }
                        )
                        .id(item.id)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .onChange(of: clipboardManager.selectedIndex) { _, newValue in
                if let item = filteredItems[safe: newValue] {
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(item.id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            HStack(spacing: 12) {
                Label("↑↓ Navigate", systemImage: "arrow.up.arrow.down")
                Label("↩ Paste", systemImage: "return")
                Label(shortcutDisplay, systemImage: "keyboard")
            }
            .font(.system(size: 10))
            .foregroundStyle(.secondary.opacity(0.5))
            Spacer()
            Button(action: { clipboardManager.clearHistory() }) {
                Label("Clear", systemImage: "trash")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }
}
