import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    var onPaste: () -> Void
    var onDelete: () -> Void
    var onPin: () -> Void
    @State private var isHovered = false

    private var showActions: Bool { isHovered || isSelected }

    var body: some View {
        HStack(spacing: 0) {
            if item.isPinned { pinIndicator }
            itemContent
            Spacer(minLength: 8)
            if showActions { actionButtons }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .background(rowBackground)
        .animation(.easeOut(duration: 0.12), value: isHovered)
        .animation(.easeOut(duration: 0.12), value: isSelected)
        .onHover { isHovered = $0 }
        .onTapGesture { onPaste() }
    }

    // MARK: - Pin Indicator

    private var pinIndicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.orange)
            .frame(width: 3, height: 24)
            .padding(.trailing, 8)
    }

    // MARK: - Content

    private var itemContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.text)
                .font(.system(size: 13))
                .lineLimit(2)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.orange)
                }
                Text(item.timestamp.formatted(.relative(presentation: .named)))
                    .font(.system(size: 10))
                    .foregroundStyle(
                        isSelected ? Color.white.opacity(0.6) : Color.secondary
                    )
            }
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 4) {
            CircleButton(
                icon: item.isPinned ? "pin.slash" : "pin",
                isSelected: isSelected,
                action: onPin
            )
            CircleButton(icon: "xmark", isSelected: isSelected, action: onDelete)
        }
        .transition(.opacity.animation(.easeOut(duration: 0.12)))
    }

    // MARK: - Background

    @ViewBuilder
    private var rowBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.tint.opacity(0.85))
                .shadow(color: .accentColor.opacity(0.2), radius: 4, y: 2)
        } else if isHovered {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.primary.opacity(0.05))
        }
    }
}
