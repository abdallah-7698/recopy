import SwiftUI

struct EmptyStateView: View {
    let hasSearchText: Bool

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clipboard")
                .font(.system(size: 32))
                .foregroundStyle(.secondary.opacity(0.3))
            Text(hasSearchText ? "No results" : "Nothing copied yet")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
