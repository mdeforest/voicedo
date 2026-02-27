import SwiftUI
import SwiftData

/// Displays the tasks within a single TaskList.
///
/// Phase 1: Placeholder with empty state.
/// Phase 2: Full task list with nesting, reorder, completion, and CRUD.
struct ListDetailView: View {

    let taskList: TaskList

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            emptyStatePlaceholder
            Spacer()
        }
        .navigationTitle(taskList.name)
        .navigationBarTitleDisplayMode(.large)
        // Phase 2: .toolbar with + button and sorting options
        // Phase 3: floating mic button
    }

    // MARK: - Subviews

    private var emptyStatePlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: taskList.icon ?? "list.bullet")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)

            Text("No Tasks Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text("Task management arrives in Phase 2.\nFor now, enjoy the calm.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ListDetailView(taskList: TaskList(name: "Inbox", icon: "tray", sortOrder: 0, isInbox: true))
    }
    .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
