import SwiftUI

/// Full task detail view: title, notes, due date, reminder, subtasks.
///
/// Phase 1: Placeholder.
/// Phase 2: Editable title and notes, list picker.
/// Phase 5: Reminder date picker, notification scheduling.
struct TaskDetailView: View {

    let task: Task

    var body: some View {
        Form {
            Section {
                Text(task.title)
                    .font(.body)
            }

            Section("Details") {
                if let notes = task.notes {
                    Text(notes)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No notes")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        // Phase 2: Replace with editable Form fields
        // Phase 5: Add reminder picker
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TaskDetailView(task: Task(title: "Buy groceries", notes: "Milk, eggs, bread"))
    }
    .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
