import SwiftUI

struct KeyboardShortcutsModifier: ViewModifier {
    @Binding var selectedIndex: Int
    let itemCount: Int
    let onPaste: () -> Void
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .onKeyPress(.upArrow) {
                if selectedIndex > 0 { selectedIndex -= 1 }
                return .handled
            }
            .onKeyPress(.downArrow) {
                if selectedIndex < itemCount - 1 { selectedIndex += 1 }
                return .handled
            }
            .onKeyPress(.return) {
                onPaste()
                return .handled
            }
            .onKeyPress(.escape) {
                onDismiss()
                return .handled
            }
    }
}

extension View {
    func keyboardShortcuts(
        selectedIndex: Binding<Int>,
        itemCount: Int,
        onPaste: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(KeyboardShortcutsModifier(
            selectedIndex: selectedIndex,
            itemCount: itemCount,
            onPaste: onPaste,
            onDismiss: onDismiss
        ))
    }
}
