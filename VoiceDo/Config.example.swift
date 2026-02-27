// Config.example.swift — Safe to commit. Contains no real secrets.
//
// Setup instructions:
//   1. Copy this file to Config.swift (same directory)
//   2. Replace "YOUR_API_KEY_HERE" with your Anthropic API key
//   3. Confirm Config.swift is gitignored before committing
//
// Get your API key at: https://console.anthropic.com

import Foundation

enum Config {
    /// Your Anthropic API key. Used by ClaudeAPIService in Phase 4.
    static let anthropicAPIKey = "YOUR_API_KEY_HERE"
}
