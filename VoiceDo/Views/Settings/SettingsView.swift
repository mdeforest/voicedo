import SwiftUI

/// App settings screen.
///
/// Phase 1: Placeholder.
/// Phase 6: Notification preferences, default reminder times, about/credits.
struct SettingsView: View {

    var body: some View {
        NavigationStack {
            List {
                Section {
                    infoRow(label: "Version", value: "1.0.0")
                    infoRow(label: "Build", value: "Phase 1")
                }

                Section("Coming Soon") {
                    Label("Notification Preferences", systemImage: "bell")
                        .foregroundStyle(.secondary)
                    Label("Default Reminder Times", systemImage: "clock")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Text("Full settings arrive in Phase 6. The important stuff — like the voice button — comes first.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
