import SwiftUI

/// A reusable empty-state view with an icon, title, and description.
/// Used throughout the app for empty lists, failed loads, etc.
struct EmptyStateView: View {

    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(
        systemImage: "mic.slash",
        title: "Nothing here yet",
        message: "Tap the mic button to get started."
    )
}
