import SwiftUI
import SwiftData

/// A single row in the Home screen's list of TaskLists.
/// Shows the list icon (colored), list name, and pending task count.
struct TaskListRow: View {

    let taskList: TaskList

    /// Count of tasks that are not yet complete.
    private var pendingCount: Int {
        taskList.tasks.filter { !$0.isComplete }.count
    }

    /// The list's accent color. Falls back to system blue if no color is set.
    private var accentColor: Color {
        if let hex = taskList.color {
            return Color(hex: hex)
        }
        return .blue
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 14) {
            listIcon
            Text(taskList.name)
                .font(.body)
            Spacer()
            taskCountBadge
        }
        .padding(.vertical, 2)
    }

    // MARK: - Subviews

    /// Colored rounded-square icon, matching Things 3's visual style.
    private var listIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(accentColor.opacity(0.15))
                .frame(width: 34, height: 34)

            Image(systemName: taskList.icon ?? "list.bullet")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(accentColor)
        }
        // Ensure minimum 44pt touch target even though this is inside a NavigationLink
        .accessibilityHidden(true)
    }

    /// Pending task count, hidden when there are no tasks.
    @ViewBuilder
    private var taskCountBadge: some View {
        if pendingCount > 0 {
            Text("\(pendingCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        TaskListRow(taskList: TaskList(name: "Inbox", icon: "tray", sortOrder: 0, isInbox: true))
        TaskListRow(taskList: TaskList(name: "Work", icon: "briefcase", sortOrder: 1))
        TaskListRow(taskList: TaskList(name: "Errands", color: "E67E22", icon: "cart", sortOrder: 2))
    }
    .listStyle(.insetGrouped)
    .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
