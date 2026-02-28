import SwiftUI

/// Floating mic button shown at the bottom-center of Home and List screens.
/// Tapping it presents the VoiceInputView sheet.
struct MicButton: View {

    @Binding var isPresented: Bool

    var body: some View {
        Button {
            isPresented = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.accentColor.opacity(0.35), radius: 10, x: 0, y: 4)

                Image(systemName: "mic.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add tasks by voice")
    }
}
