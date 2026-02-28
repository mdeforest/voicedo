import SwiftUI

/// Half-sheet overlay for voice task capture.
///
/// State machine driven by `SpeechService.recordingState`:
/// - `.idle` → starts recording automatically on appear
/// - `.recording` → animated mic, live transcript, Stop button
/// - `.stopped` → final transcript, Done button (Phase 4: will trigger Claude API)
/// - `.permissionDenied` → friendly message with Settings link
/// - `.error` → calm error message
struct VoiceInputView: View {

    @Binding var isPresented: Bool
    private let speechService = SpeechService.shared

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            handle

            switch speechService.recordingState {
            case .idle:
                // Briefly visible while startRecording() is called on appear
                Color.clear.frame(height: 200)

            case .recording:
                recordingContent

            case .stopped:
                stoppedContent

            case .permissionDenied(let type):
                permissionDeniedContent(type)

            case .error(let message):
                errorContent(message)
            }
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
        .onAppear {
            _Concurrency.Task { await speechService.startRecording() }
        }
        .onDisappear {
            speechService.reset()
        }
    }

    // MARK: - Handle

    private var handle: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.3))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    // MARK: - Recording state

    private var recordingContent: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 16)

            micAnimation

            transcriptArea

            stopButton

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 24)
    }

    private var micAnimation: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 96, height: 96)
                .scaleEffect(speechService.recordingState == .recording ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                           value: speechService.recordingState == .recording)

            // Inner circle
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 72, height: 72)

            // Mic icon
            Image(systemName: "mic.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.pulse)
        }
    }

    private var transcriptArea: some View {
        ScrollView {
            Group {
                if speechService.transcript.isEmpty {
                    Text("Listening…")
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text(speechService.transcript)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .font(.title3)
            .padding(.bottom, 28)
            .animation(.easeInOut(duration: 0.15), value: speechService.transcript)
        }
        .frame(maxHeight: 160)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.70),
                    .init(color: .clear, location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var stopButton: some View {
        Button {
            speechService.stopRecording()
        } label: {
            Label("Stop", systemImage: "stop.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stopped state

    private var stoppedContent: some View {
        VStack(spacing: 24) {
            Spacer()

            // Status icon — same circle bubble and icon size as the mic animation
            stoppedIcon

            if speechService.transcript.isEmpty {
                Text("Nothing recorded")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                // Final transcript display
                ScrollView {
                    Text(speechService.transcript)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 28)
                }
                .frame(maxHeight: 160)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.70),
                            .init(color: .clear, location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Phase 4: replace this button with "Create Tasks" that calls ClaudeAPIService
            Button {
                isPresented = false
            } label: {
                Text(speechService.transcript.isEmpty ? "Dismiss" : "Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        speechService.transcript.isEmpty ? Color.secondary : Color.accentColor,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    /// Mirrors the size and circle structure of `micAnimation` for visual consistency.
    private var stoppedIcon: some View {
        let hasTranscript = !speechService.transcript.isEmpty
        return ZStack {
            Circle()
                .fill(hasTranscript ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
                .frame(width: 96, height: 96)
            Circle()
                .fill(hasTranscript ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.12))
                .frame(width: 72, height: 72)
            Image(systemName: hasTranscript ? "checkmark" : "mic.slash")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(hasTranscript ? Color.accentColor : Color.secondary.opacity(0.5))
        }
    }

    // MARK: - Permission denied state

    private func permissionDeniedContent(_ type: SpeechService.RecordingState.PermissionType) -> some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "mic.slash.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(type == .microphone ? "Microphone Access Needed" : "Speech Recognition Needed")
                    .font(.headline)

                Text(type == .microphone
                    ? "VoiceDo needs microphone access to capture your tasks. You can enable it in Settings."
                    : "VoiceDo needs speech recognition access to transcribe your voice. You can enable it in Settings."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)

            Button("Dismiss") {
                isPresented = false
            }
            .foregroundStyle(.secondary)
            .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Error state

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.headline)
                Text("Speech recognition hit a snag. You can try again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Try Again") {
                _Concurrency.Task { await speechService.startRecording() }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)

            Button("Dismiss") {
                isPresented = false
            }
            .foregroundStyle(.secondary)
            .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Preview

#Preview {
    Color.appBackground
        .sheet(isPresented: .constant(true)) {
            VoiceInputView(isPresented: .constant(true))
        }
}
