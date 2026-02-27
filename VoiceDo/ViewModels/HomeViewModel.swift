import Foundation
import Observation
import SwiftData

/// ViewModel for the Home screen (list-of-lists).
///
/// Data fetching is handled by @Query in HomeView (SwiftData's reactive layer).
/// This ViewModel owns presentation state and will gain list CRUD actions in Phase 2.
@Observable
final class HomeViewModel {

    // MARK: - Presentation State

    /// Controls visibility of the "New List" creation sheet (Phase 2).
    var isAddListPresented = false

    // MARK: - Phase 2 TODOs
    //
    // - createList(name:color:icon:)
    // - deleteList(_ list: TaskList, moveTasksToInbox: Bool)
    // - renameList(_ list: TaskList, newName: String)
    // - reorderLists(from source: IndexSet, to destination: Int)

    init() {}
}
