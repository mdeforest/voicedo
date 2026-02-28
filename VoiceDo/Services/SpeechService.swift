import Foundation
import Speech
import AVFoundation
import OSLog

/// Wraps Apple's SFSpeechRecognizer and AVAudioEngine for on-device voice-to-text.
///
/// - Requests microphone and speech recognition permissions on first call to `startRecording()`.
/// - Publishes live partial transcripts via the `transcript` property.
/// - Auto-stops after `Constants.Voice.silenceTimeout` seconds of silence (only after first result).
/// - Hard-stops after `Constants.Voice.maxRecordingDuration` seconds regardless.
@Observable
final class SpeechService {

    static let shared = SpeechService()

    // MARK: - Observed state

    private(set) var transcript = ""
    private(set) var recordingState: RecordingState = .idle

    enum RecordingState: Equatable {
        case idle
        case recording
        case stopped
        case permissionDenied(PermissionType)
        case error(String)

        enum PermissionType: Equatable {
            case microphone, speech
        }
    }

    // MARK: - Private

    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private var maxDurationTimer: Timer?

    private let log = Logger(subsystem: "com.voicedo.app", category: "SpeechService")

    private init() {}

    // MARK: - Public API

    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus {
        SFSpeechRecognizer.authorizationStatus()
    }

    /// Requests speech recognition permission.
    func requestPermission() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    /// Checks permissions, then starts audio capture and speech recognition.
    @MainActor
    func startRecording() async {
        log.info("startRecording() called")
        transcript = ""

        // --- Speech recognition permission ---
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        log.info("Speech auth status: \(String(describing: speechStatus.rawValue))")

        if speechStatus == .notDetermined {
            let status = await requestPermission()
            log.info("Speech permission result: \(String(describing: status.rawValue))")
            guard status == .authorized else {
                recordingState = .permissionDenied(.speech)
                return
            }
        } else if speechStatus != .authorized {
            log.warning("Speech recognition not authorized — showing permission denied")
            recordingState = .permissionDenied(.speech)
            return
        }

        // --- Microphone permission (AVAudioApplication API, iOS 17+) ---
        let micGranted: Bool = await AVAudioApplication.requestRecordPermission()
        log.info("Microphone permission granted: \(micGranted)")
        guard micGranted else {
            recordingState = .permissionDenied(.microphone)
            return
        }

        // --- Begin recognition (we're back on MainActor after the awaits) ---
        do {
            try beginRecognition()
            recordingState = .recording
            log.info("Recording started successfully")
        } catch {
            log.error("beginRecognition() threw: \(error.localizedDescription)")
            recordingState = .error(error.localizedDescription)
        }
    }

    /// Stops recording and transitions to `.stopped`.
    func stopRecording() {
        log.info("stopRecording() called manually")
        finishRecording()
    }

    /// Resets all state back to `.idle` — call this when the sheet is dismissed.
    func reset() {
        log.info("reset() called")
        cleanupAudio()
        transcript = ""
        recordingState = .idle
    }

    // MARK: - Private helpers

    private func beginRecognition() throws {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            log.error("SFSpeechRecognizer unavailable (recognizer=\(self.speechRecognizer == nil ? "nil" : "exists"), available=\(self.speechRecognizer?.isAvailable ?? false))")
            throw RecognitionError.recognizerUnavailable
        }
        log.info("SFSpeechRecognizer available, locale: \(recognizer.locale.identifier)")

        // Configure audio session for recording
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        log.info("Audio session configured — category=record, mode=measurement")

        // Create recognition request
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        // Start recognition task — callback fires on a background queue
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let text = result.bestTranscription.formattedString
                self.log.info("Partial result: \"\(text)\" isFinal=\(result.isFinal)")
                DispatchQueue.main.async {
                    // Guard against the empty final result iOS emits when closing
                    // the session — it would overwrite the last real transcript.
                    if !text.isEmpty {
                        self.transcript = text
                        self.resetSilenceTimer()
                    }
                }
            }

            if let error = error as NSError? {
                // 216 = recognition cancelled (expected on manual stop)
                // 203 = no speech detected (expected after silence timeout)
                self.log.info("Recognition error code=\(error.code) domain=\(error.domain): \(error.localizedDescription)")
                if error.code != 216 && error.code != 203 {
                    DispatchQueue.main.async {
                        if self.recordingState == .recording {
                            self.recordingState = .error(error.localizedDescription)
                            self.cleanupAudio()
                        }
                    }
                }
            }

            if result?.isFinal == true {
                self.log.info("Final result received — finishing recording")
                DispatchQueue.main.async { self.finishRecording() }
            }
        }

        // Install audio tap → feeds buffers into the recognition request
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        log.info("Input node format: sampleRate=\(format.sampleRate) channels=\(format.channelCount)")
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        log.info("Audio engine started")

        // Only start the max-duration hard cap now.
        // The silence timer starts only after the first partial result arrives,
        // so users have unlimited time to begin speaking.
        startMaxDurationTimer()
    }

    private func finishRecording() {
        guard recordingState == .recording else { return }
        log.info("finishRecording() — transcript length: \(self.transcript.count) chars")
        cleanupAudio()
        recordingState = .stopped
    }

    private func cleanupAudio() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        maxDurationTimer?.invalidate()
        maxDurationTimer = nil

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        log.info("Audio cleaned up")
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.Voice.silenceTimeout,
            repeats: false
        ) { [weak self] _ in
            self?.log.info("Silence timer fired — auto-stopping")
            DispatchQueue.main.async { self?.finishRecording() }
        }
    }

    private func startMaxDurationTimer() {
        maxDurationTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.Voice.maxRecordingDuration,
            repeats: false
        ) { [weak self] _ in
            self?.log.info("Max duration timer fired — force-stopping")
            DispatchQueue.main.async { self?.finishRecording() }
        }
    }

    // MARK: - Errors

    private enum RecognitionError: LocalizedError {
        case recognizerUnavailable
        var errorDescription: String? { "Speech recognition is not available right now." }
    }
}
