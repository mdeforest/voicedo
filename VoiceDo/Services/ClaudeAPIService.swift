import Foundation

// MARK: - ParsedTask

/// A task extracted from a voice transcript by the Claude API.
/// Used as the bridge between the API response and SwiftData Task creation.
struct ParsedTask {
    let title: String
    /// ISO 8601 date inferred from the transcript (e.g. "tomorrow" → next day 9 AM).
    let dueDate: Date?
    /// List name suggested by Claude (e.g. "Grocery"). May not match an existing list.
    let listName: String?
}

// MARK: - ClaudeAPIService

/// Client for the Anthropic Claude API.
///
/// Phase 1: Stub with type definitions.
/// Phase 4: Full implementation — sends transcript to Claude, parses structured task JSON,
///          handles errors and rate limiting, falls back to raw transcript on failure.
///
/// API endpoint: POST https://api.anthropic.com/v1/messages
/// Model: claude-sonnet-4-20250514
final class ClaudeAPIService {

    static let shared = ClaudeAPIService()
    private init() {}

    // MARK: - Phase 4 Implementation

    /// Parses a voice transcript into structured tasks using the Claude API.
    ///
    /// - Parameter text: The raw voice transcript string.
    /// - Returns: An array of ParsedTask values extracted from the transcript.
    /// - Throws: `ClaudeAPIError` on network failure, API error, or malformed response.
    func parseTranscript(_ text: String) async throws -> [ParsedTask] {
        // TODO: Phase 4 — implement the full API call
        // 1. Build URLRequest with Anthropic headers and JSON body
        // 2. Send via URLSession with Constants.API.requestTimeout
        // 3. Decode response JSON into [ParsedTask]
        // 4. Handle 429 with exponential backoff (max Constants.API.maxRetries)
        // 5. On any error, throw ClaudeAPIError for the caller to fall back to raw transcript
        throw ClaudeAPIError.notImplemented
    }

    // MARK: - Errors

    enum ClaudeAPIError: LocalizedError {
        case notImplemented
        case networkError(Error)
        case httpError(statusCode: Int, message: String)
        case invalidResponse
        case rateLimited

        var errorDescription: String? {
            switch self {
            case .notImplemented:
                return "Claude API integration is not yet implemented (coming in Phase 4)."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .httpError(let code, let message):
                return "API error \(code): \(message)"
            case .invalidResponse:
                return "The API returned an unexpected response format."
            case .rateLimited:
                return "Too many requests. Please try again in a moment."
            }
        }
    }
}
