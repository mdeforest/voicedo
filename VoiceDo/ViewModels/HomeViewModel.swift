import Foundation
import Observation
import SwiftData

/// ViewModel for the Home screen (list-of-lists).
///
/// Data fetching is handled by @Query in HomeView (SwiftData's reactive layer).
/// This ViewModel owns presentation state and list CRUD actions.
@Observable
final class HomeViewModel {

    // MARK: - Presentation State

    /// Controls visibility of the "New List" creation sheet.
    var isAddListPresented = false
    /// Controls the delete confirmation alert.
    var isDeleteListAlertPresented = false
    /// The list awaiting deletion — set before the alert appears, cleared on cancel.
    var listPendingDeletion: TaskList? = nil

    // MARK: - List Creation

    /// Creates a new named list and inserts it into the store.
    func createList(
        name: String,
        color: String?,
        icon: String?,
        context: ModelContext,
        allLists: [TaskList]
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let maxSort = allLists.map { $0.sortOrder }.max() ?? 0
        let list = TaskList(name: trimmed, color: color, icon: icon, sortOrder: maxSort + 1)
        context.insert(list)
        try? context.save()
    }

    // MARK: - List Deletion

    /// Optionally re-parents all tasks to Inbox, then deletes the list.
    /// The Inbox is protected by the UI — no context menu is offered for it.
    func deleteList(
        _ list: TaskList,
        moveTasksToInbox: Bool,
        inbox: TaskList?,
        context: ModelContext
    ) {
        if moveTasksToInbox, let inbox {
            for task in list.tasks { task.taskList = inbox }
        }
        context.delete(list)
        try? context.save()
        listPendingDeletion = nil
    }

    // MARK: - Phase 6 TODO
    // - reorderLists: LazyVGrid doesn't support .onMove; defer to Phase 6.

    init() {}
}
