import Foundation
import SwiftData

/// A single to-do item. Tasks can be nested up to Constants.Task.maxNestingDepth (5) levels
/// using the self-referential parent/children relationship.
///
/// Note: This class is named `Task`, which shadows Swift's `_Concurrency.Task` type
/// in files that import this module. If you need Swift's async Task in the same scope,
/// use `_Concurrency.Task { ... }` explicitly.
@Model
final class Task {

    // MARK: - Attributes

    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String?
    var isComplete: Bool
    var dueDate: Date?
    /// When set, a local notification is scheduled via NotificationService (Phase 5).
    var reminderDate: Date?
    /// Position within the parent task's children (or within the list for root tasks).
    var sortOrder: Int
    var createdAt: Date
    /// Set automatically when isComplete transitions to true.
    var completedAt: Date?

    // MARK: - Relationships

    /// The list this task belongs to. Every task belongs to exactly one list.
    var taskList: TaskList?

    /// Parent task for nested subtasks. Nil for root-level tasks.
    var parent: Task?

    /// Direct child tasks (subtasks). Cascade delete: deleting a task deletes all its subtasks.
    /// In Phase 2, the delete flow will offer to promote children first.
    @Relationship(deleteRule: .cascade)
    var children: [Task] = []

    // MARK: - Init

    init(
        title: String,
        notes: String? = nil,
        isComplete: Bool = false,
        dueDate: Date? = nil,
        reminderDate: Date? = nil,
        sortOrder: Int = 0,
        taskList: TaskList? = nil,
        parent: Task? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.completedAt = nil
        self.taskList = taskList
        self.parent = parent
    }
}
