import SwiftUI
import SwiftData

/// Full editable task detail view.
///
/// Uses @Bindable to bind directly to the SwiftData model — SwiftData's autosave
/// persists field edits automatically. No explicit Save button needed.
struct TaskDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Task

    private var metadataParts: [String] {
        var parts = ["Created \(task.createdAt.formatted(date: .abbreviated, time: .shortened))"]
        if let completedAt = task.completedAt {
            parts.append("Completed \(completedAt.formatted(date: .abbreviated, time: .shortened))")
        }
        if let list = task.taskList {
            parts.append(list.name)
        }
        return parts
    }

    var body: some View {
        Form {
            // Title — editable, multiline
            Section {
                TextField("Task title", text: $task.title, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...5)
            }

            // Notes — editable, multiline, nil-safe binding
            Section("Notes") {
                TextField(
                    "Add notes...",
                    text: Binding(
                        get: { task.notes ?? "" },
                        set: { task.notes = $0.isEmpty ? nil : $0 }
                    ),
                    axis: .vertical
                )
                .font(.body)
                .lineLimit(3...8)
            }

            // Due Date — footer carries the read-only metadata caption
            Section {
                if task.dueDate != nil {
                    DatePicker(
                        "Due",
                        selection: Binding(
                            get: { task.dueDate ?? Date() },
                            set: { task.dueDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )
                    Button("Remove due date", role: .destructive) {
                        task.dueDate = nil
                    }
                    .font(.subheadline)
                } else {
                    Button("Add due date") {
                        task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    }
                }
            } header: {
                Text("Due Date")
            } footer: {
                Text(metadataParts.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Phase 5: Add reminder picker section here
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TaskDetailView(task: Task(
            title: "Buy groceries",
            notes: "Milk, eggs, bread",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        ))
    }
    .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
