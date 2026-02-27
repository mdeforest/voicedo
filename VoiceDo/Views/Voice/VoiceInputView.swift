import SwiftUI

/// Voice Input Overlay — the half-sheet that appears while the user is recording.
/// Displays a live transcript, stop button, and recording status.
///
/// Phase 1: Placeholder shell.
/// Phase 3: Full SFSpeechRecognizer integration, live transcript, auto-stop on silence.
/// Phase 4: Wires into ClaudeAPIService to show review cards after recording.
struct VoiceInputView: View {

    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            Spacer()

            Image(systemName: "mic.fill")
                .font(.system(size: 52))
                .foregroundStyle(.blue)
                .symbolEffect(.pulse)

            Text("Voice input coming in Phase 3")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Dismiss") {
                isPresented = false
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)  // We draw our own handle above
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            VoiceInputView(isPresented: .constant(true))
        }
}
