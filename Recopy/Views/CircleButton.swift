import SwiftUI

struct CircleButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(isSelected ? .white.opacity(0.15) : .primary.opacity(0.05))
                        .overlay(
                            Circle().strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
