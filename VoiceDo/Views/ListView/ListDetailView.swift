import SwiftUI
import SwiftData
import UIKit

/// Displays the tasks within a single TaskList.
///
/// Phase 2: Full task list with inline creation, completion toggle,
/// swipe-to-delete, drag-to-reorder, and collapsible Done section.
struct ListDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ListDetailViewModel()
    @Bindable var taskList: TaskList
    @FocusState private var isNewTaskFieldFocused: Bool
    /// Prevents `onChange(of: isNewTaskFieldFocused)` from closing the row when
    /// Return is pressed — iOS briefly drops focus on TextField submit.
    @State private var isSubmittingTask = false
    @State private var isEditListPresented = false
    @State private var isVoiceInputPresented = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            content

            // Floating mic button — bottom-center, above home indicator
            VStack {
                Spacer()
                MicButton(isPresented: $isVoiceInputPresented)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle(taskList.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .toolbar { keyboardToolbar }
        .environment(\.editMode, $viewModel.editMode)
        .sheet(isPresented: $isEditListPresented) {
            EditListSheet(taskList: taskList)
        }
        .sheet(isPresented: $isVoiceInputPresented) {
            VoiceInputView(isPresented: $isVoiceInputPresented)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if taskList.tasks.isEmpty && !viewModel.isAddingTask {
            emptyState
        } else {
            taskListView
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            systemImage: taskList.icon ?? "list.bullet",
            title: "No tasks yet",
            message: "Tap + to add your first task."
        )
    }

    // MARK: - Task List

    private var taskListView: some View {
        List {
            // Inline new-task row — appears at top when isAddingTask is true
            if viewModel.isAddingTask {
                newTaskRow
            }

            // Pending tasks
            let pending = viewModel.pendingTasks(in: taskList)
            ForEach(pending) { task in
                TaskRow(task: task, viewModel: viewModel)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                    .listRowSeparator(.hidden)
            }
            .onMove { source, destination in
                viewModel.movePendingTasks(from: source, to: destination, in: taskList, context: modelContext)
            }
            .onDelete { offsets in
                viewModel.deletePendingTasks(at: offsets, in: taskList, context: modelContext)
            }

            // Done section — collapsible
            let completed = viewModel.completedTasks(in: taskList)
            if !completed.isEmpty {
                doneSectionView(completed: completed)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            dismissAllFocus()
        }
    }

    // MARK: - New Task Row

    private var newTaskRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle")
                .font(.system(size: 20))
                .foregroundStyle(.tertiary)

            TextField("New task", text: $viewModel.newTaskTitle)
                .focused($isNewTaskFieldFocused)
                .onSubmit {
                    isSubmittingTask = true
                    viewModel.createTask(in: taskList, context: modelContext)
                    // Re-focus next run loop after iOS drops focus on Return
                    DispatchQueue.main.async {
                        isNewTaskFieldFocused = true
                        isSubmittingTask = false
                    }
                }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
        .listRowSeparator(.hidden)
        .onAppear {
            isNewTaskFieldFocused = true
        }
        .onChange(of: isNewTaskFieldFocused) { _, focused in
            // Skip if Return was pressed (handled by onSubmit) or row already closed.
            guard !focused, !isSubmittingTask, viewModel.isAddingTask else { return }
            // Focus lost naturally (e.g. tap on another row) — save and close.
            viewModel.createTask(in: taskList, context: modelContext)
            viewModel.isAddingTask = false
        }
    }

    // MARK: - Done Section

    private func doneSectionView(completed: [Task]) -> some View {
        Section {
            if viewModel.isDoneSectionExpanded {
                ForEach(completed) { task in
                    TaskRow(task: task, viewModel: viewModel)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                        .listRowSeparator(.hidden)
                }
                .onDelete { offsets in
                    viewModel.deleteCompletedTasks(at: offsets, in: taskList, context: modelContext)
                }
            }
        } header: {
            doneSectionHeader(count: completed.count, completed: completed)
        }
        .listRowBackground(Color.clear)
    }

    private func doneSectionHeader(count: Int, completed: [Task]) -> some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.isDoneSectionExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .rotationEffect(.degrees(viewModel.isDoneSectionExpanded ? 90 : 0))
                        .animation(.spring(duration: 0.25), value: viewModel.isDoneSectionExpanded)

                    Text("Done")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.6), in: Capsule())
                }
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(role: .destructive) {
                for task in completed {
                    viewModel.deleteTask(task, context: modelContext)
                }
            } label: {
                Text("Clear All")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            EditButton()
            if !taskList.isInbox {
                Button {
                    isEditListPresented = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            Button {
                viewModel.isAddingTask = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }

    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                viewModel.createTask(in: taskList, context: modelContext)
                viewModel.isAddingTask = false
                dismissAllFocus()
            }
        }
    }

    // MARK: - Helpers

    private func dismissAllFocus() {
        isNewTaskFieldFocused = false
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ListDetailView(taskList: TaskList(name: "Inbox", icon: "tray", sortOrder: 0, isInbox: true))
    }
    .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
