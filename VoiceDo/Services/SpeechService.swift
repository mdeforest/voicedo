import Foundation
import Speech
import AVFoundation

/// Wraps Apple's SFSpeechRecognizer and AVAudioEngine for on-device voice-to-text.
///
/// Phase 1: Stub with permission helpers.
/// Phase 3: Full implementation — starts/stops recording, publishes live partial results,
///          detects silence after Constants.Voice.silenceTimeout seconds, enforces
///          Constants.Voice.maxRecordingDuration limit.
final class SpeechService {

    static let shared = SpeechService()
    private init() {}

    // MARK: - Permissions

    /// Current speech recognition authorization status.
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus {
        SFSpeechRecognizer.authorizationStatus()
    }

    /// Requests speech recognition permission from the user.
    /// The microphone permission is requested separately when recording starts.
    func requestPermission() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    // MARK: - Phase 3 TODOs
    //
    // - startRecording() -> AsyncStream<String>   (emits partial transcripts)
    // - stopRecording()
    // - Private: configureAudioSession()
    // - Private: detectSilence(lastResultDate: Date)
    // - Handle permission denial: surface a user-facing message with link to Settings
}
