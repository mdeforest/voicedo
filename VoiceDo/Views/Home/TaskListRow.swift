import SwiftUI
import SwiftData

/// Card component for a TaskList on the Home screen. Two visual styles:
///
/// - **Hero** (`isHero: true`): Full-width, used for the Inbox. Taller card with
///   icon, name, and pending count laid out vertically on the left.
/// - **Grid** (`isHero: false`): Half-width, used in the 2-column user list grid.
///   Icon at top-left, name and count below.
///
/// Background color cycles through `Color.cardPalette` for grid cards,
/// and uses a fixed lavender for the hero card, unless the list has a custom `color`.
struct TaskListCard: View {

    let taskList: TaskList
    var isHero: Bool = false
    /// Index within the user list array — drives the card palette cycle.
    var colorIndex: Int = 0

    private var pendingCount: Int {
        taskList.tasks.filter { !$0.isComplete }.count
    }

    private var backgroundColor: Color {
        if let hex = taskList.color { return Color(hex: hex) }
        return isHero ? Color(hex: "CBC3F0") : Color.cardPalette[colorIndex % Color.cardPalette.count]
    }

    private var countLabel: String {
        pendingCount == 0 ? "All clear" : "\(pendingCount) task\(pendingCount == 1 ? "" : "s")"
    }

    // MARK: - Body

    var body: some View {
        if isHero {
            heroCard
        } else {
            gridCard
        }
    }

    // MARK: - Hero (Inbox)

    private var heroCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                iconBubble
                    .padding(.bottom, 20)
                Text(taskList.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text(countLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Grid (user lists)

    private var gridCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            iconBubble
            Spacer(minLength: 16)
            Text(taskList.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
            Text("\(pendingCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Icon bubble

    /// SF Symbol in a frosted white circle, matching the reference design.
    private var iconBubble: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.5))
                .frame(width: 40, height: 40)
            Image(systemName: taskList.icon ?? "list.bullet")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary.opacity(0.75))
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            TaskListCard(
                taskList: TaskList(name: "Inbox", icon: "tray", sortOrder: 0, isInbox: true),
                isHero: true
            )
            HStack(spacing: 12) {
                TaskListCard(
                    taskList: TaskList(name: "Work", icon: "briefcase", sortOrder: 1),
                    colorIndex: 0
                )
                TaskListCard(
                    taskList: TaskList(name: "Errands", icon: "cart", sortOrder: 2),
                    colorIndex: 1
                )
            }
            HStack(spacing: 12) {
                TaskListCard(
                    taskList: TaskList(name: "Home", icon: "house", sortOrder: 3),
                    colorIndex: 2
                )
                TaskListCard(
                    taskList: TaskList(name: "Health", icon: "heart", sortOrder: 4),
                    colorIndex: 3
                )
            }
        }
        .padding()
    }
    .background(Color.appBackground)
    .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
