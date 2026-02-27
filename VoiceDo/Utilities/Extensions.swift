import SwiftUI

// MARK: - Color + Hex

extension Color {
    /// Creates a Color from a hex string (e.g. "#4A90E2" or "4A90E2").
    /// Supports 3-digit (RGB), 6-digit (RRGGBB), and 8-digit (AARRGGBB) formats.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit shorthand)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RRGGBB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // AARRGGBB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 200, 200, 200)  // Fallback: light gray
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date + Display Formatting

extension Date {
    /// Short date string for task rows. Shows "Feb 26" for current year, "Feb 26, 2025" otherwise.
    var shortDisplay: String {
        let formatter = DateFormatter()
        if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: self)
    }

    /// Returns true if the date is earlier than today (ignoring time).
    var isOverdue: Bool {
        Calendar.current.startOfDay(for: self) < Calendar.current.startOfDay(for: Date())
    }

    /// Returns true if the date falls on today.
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
