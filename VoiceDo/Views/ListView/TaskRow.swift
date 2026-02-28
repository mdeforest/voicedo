import SwiftUI
import SwiftData

/// A single task row. Interaction zones:
///
/// - **Checkbox (left)** — toggles completion with animation.
/// - **Title / whitespace (center)** — tap to edit the title inline.
/// - **">" chevron (right)** — tap to open `TaskDetailView`.
/// - **Trailing swipe** — delete.
/// - **Context menu** — View Details, Delete.
struct TaskRow: View {

    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Task

    let viewModel: ListDetailViewModel

    @State private var isEditingTitle = false
    @FocusState private var isTitleFocused: Bool
    @State private var navigateToDetail = false

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            checkboxButton
            contentArea
            chevronButton
        }
        .padding(.vertical, 7)
        // navigationDestination registers on the nearest NavigationStack;
        // applying it per-row avoids any gesture conflict with the content area.
        .navigationDestination(isPresented: $navigateToDetail) {
            TaskDetailView(task: task)
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

    // MARK: - Chevron → navigate to detail

    private var chevronButton: some View {
        Button {
            navigateToDetail = true
        } label: {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View task details")
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            navigateToDetail = true
        } label: {
            Label("View Details", systemImage: "info.circle")
        }
        Button(role: .destructive) {
            viewModel.deleteTask(task, context: modelContext)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
