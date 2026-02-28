import Foundation
import Observation
import SwiftData
import SwiftUI

/// ViewModel for the List Detail screen.
///
/// Owns all task mutations: create, complete, delete, and reorder.
///
/// Data access pattern: `taskList.tasks` is a live SwiftData relationship array.
/// Because TaskList is a @Model, accessing `.tasks` registers an observation
/// dependency — mutations anywhere auto-refresh views that read this VM.
/// No secondary @Query is needed.
@Observable
final class ListDetailViewModel {

    // MARK: - Presentation State

    /// Controls the inline new-task text field at the top of the list.
    var isAddingTask = false
    /// Bound to the inline new-task TextField.
    var newTaskTitle = ""
    /// Controls the collapsible Done section.
    var isDoneSectionExpanded = false
    /// Drives the List's EditButton for drag-to-reorder.
    var editMode: EditMode = .inactive

    // MARK: - Derived Task Collections

    /// Incomplete tasks sorted by sortOrder ascending.
    func pendingTasks(in taskList: TaskList) -> [Task] {
        taskList.tasks
            .filter { !$0.isComplete }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Complete tasks sorted by completedAt descending.
    func completedTasks(in taskList: TaskList) -> [Task] {
        taskList.tasks
            .filter { $0.isComplete }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    // MARK: - Task Creation

    /// Creates a new task from `newTaskTitle` and clears the input state.
    func createTask(in taskList: TaskList, context: ModelContext) {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            isAddingTask = false
            newTaskTitle = ""
            return
        }

        let maxSort = taskList.tasks
            .map { $0.sortOrder }
            .max() ?? -1

        let task = Task(title: title, sortOrder: maxSort + 1, taskList: taskList)
        context.insert(task)
        try? context.save()

        // Keep adding mode open so the user can chain tasks with Enter.
        // The view dismisses the row when focus is lost on an empty field.
        newTaskTitle = ""
    }

    // MARK: - Task Completion

    /// Toggles isComplete and sets/clears completedAt.
    func toggleCompletion(task: Task, context: ModelContext) {
        let completing = !task.isComplete
        task.isComplete = completing
        task.completedAt = completing ? Date() : nil
        try? context.save()
    }

    // MARK: - Task Deletion

    /// Deletes a single task.
    func deleteTask(_ task: Task, context: ModelContext) {
        context.delete(task)
        try? context.save()
    }

    /// Deletes tasks at the given offsets from the pending task array. Used by List .onDelete.
    func deletePendingTasks(at offsets: IndexSet, in taskList: TaskList, context: ModelContext) {
        let pending = pendingTasks(in: taskList)
        for index in offsets {
            context.delete(pending[index])
        }
        try? context.save()
    }

    /// Deletes tasks at the given offsets from the completed task array.
    func deleteCompletedTasks(at offsets: IndexSet, in taskList: TaskList, context: ModelContext) {
        let done = completedTasks(in: taskList)
        for index in offsets {
            context.delete(done[index])
        }
        try? context.save()
    }

    // MARK: - Reordering

    /// Reorders pending tasks and updates sortOrder. Called from List .onMove.
    func movePendingTasks(from source: IndexSet, to destination: Int, in taskList: TaskList, context: ModelContext) {
        var tasks = pendingTasks(in: taskList)
        tasks.move(fromOffsets: source, toOffset: destination)
        for (index, task) in tasks.enumerated() {
            task.sortOrder = index
        }
        try? context.save()
    }
}
