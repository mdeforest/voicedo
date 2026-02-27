import Foundation

/// App-wide constants organized by feature domain.
enum Constants {

    enum Voice {
        /// Maximum recording duration in seconds (2 minutes = guards against runaway API costs).
        static let maxRecordingDuration: TimeInterval = 120
        /// Seconds of silence before recording auto-stops.
        static let silenceTimeout: TimeInterval = 3.0
        /// Word count threshold before showing a warning to the user.
        static let transcriptWordLimit = 500
    }

    enum Task {
        /// Maximum nesting depth for subtasks (prevents unusable UI).
        static let maxNestingDepth = 5
    }

    enum API {
        /// Claude API request timeout in seconds.
        static let requestTimeout: TimeInterval = 10.0
        /// Maximum retry attempts for rate-limited (429) requests.
        static let maxRetries = 3
    }

    enum Notifications {
        /// Default morning reminder hour (9:00 AM).
        static let morningHour = 9
        /// Default afternoon reminder hour (1:00 PM).
        static let afternoonHour = 13
        /// Default evening reminder hour (6:00 PM).
        static let eveningHour = 18
    }
}
