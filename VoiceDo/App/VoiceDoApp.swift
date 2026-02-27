import SwiftUI
import SwiftData

@main
struct VoiceDoApp: App {

    // MARK: - Model Container

    /// The shared SwiftData container for the entire app.
    /// Created once at startup and injected via .modelContainer() into the view hierarchy.
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: TaskList.self, Task.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("[VoiceDo] Failed to create ModelContainer: \(error)")
        }

        // Seed default Inbox on first launch (no-op if it already exists).
        seedDefaultInboxIfNeeded()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }

    // MARK: - Seeding

    /// Checks whether an Inbox list exists in the store.
    /// If not, creates and saves one. This is idempotent — safe to call on every launch.
    private func seedDefaultInboxIfNeeded() {
        let context = modelContainer.mainContext

        // Fetch any existing inbox list
        let descriptor = FetchDescriptor<TaskList>(
            predicate: #Predicate { $0.isInbox == true }
        )

        do {
            let existing = try context.fetch(descriptor)
            guard existing.isEmpty else {
                return  // Inbox already exists — nothing to do
            }

            let inbox = TaskList(
                name: "Inbox",
                color: nil,
                icon: "tray",
                sortOrder: 0,
                isInbox: true
            )
            context.insert(inbox)
            try context.save()
        } catch {
            // Non-fatal: the app is still usable without the Inbox seed
            print("[VoiceDo] Warning: Could not seed Inbox — \(error)")
        }
    }
}
