import SwiftUI
import SwiftData

/// A single task row. Interaction zones:
///
/// - **Checkbox (left)** — toggles completion with animation.
/// - **Title / whitespace (center)** — tap to edit the title inline.
/// - **">" disclosure (right)** — the List-level NavigationLink chevron; navigates to `TaskDetailView`.
/// - **Trailing swipe** — delete.
/// - **Context menu** — Delete.
struct TaskRow: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Task

    let viewModel: ListDetailViewModel

    @State private var isEditingTitle = false
    @FocusState private var isTitleFocused: Bool

    // MARK: - Body

    var body: some View {
        NavigationLink(destination: TaskDetailView(task: task)) {
            HStack(alignment: .center, spacing: 10) {
                checkboxButton
                contentArea
            }
            .padding(.vertical, 7)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deleteTask(task, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu { contextMenuContent }
    }

    // MARK: - Checkbox → toggle completion

    private var checkboxButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                viewModel.toggleCompletion(task: task, context: modelContext)
            }
        } label: {
            Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(task.isComplete ? .secondary : Color.accentColor)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.isComplete ? "Mark incomplete" : "Mark complete")
    }

    // MARK: - Content area → tap to edit inline
    // .frame(maxWidth: .infinity) + contentShape + onTapGesture means tapping
    // text OR whitespace starts inline editing and does NOT trigger NavigationLink.

    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 3) {
            if isEditingTitle {
                TextField("Task title", text: $task.title)
                    .focused($isTitleFocused)
                    .font(.body)
                    .onSubmit { isEditingTitle = false }
                    .onChange(of: isTitleFocused) { _, focused in
                        if !focused { isEditingTitle = false }
                    }
            } else {
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(task.isComplete ? .secondary : .primary)
                    .strikethrough(task.isComplete, color: .secondary)
                    .animation(.easeInOut(duration: 0.2), value: task.isComplete)
                    .lineLimit(3)
            }

            if let due = task.dueDate {
                HStack(spacing: 3) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(due.shortDisplay)
                        .font(.caption)
                }
                .foregroundStyle(due.isOverdue && !task.isComplete ? Color(hex: "E8A87C") : .secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            isEditingTitle = true
            DispatchQueue.main.async { isTitleFocused = true }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        Button(role: .destructive) {
            viewModel.deleteTask(task, context: modelContext)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
