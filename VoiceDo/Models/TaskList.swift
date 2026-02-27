import Foundation
import SwiftData

/// A named collection of tasks. The default "Inbox" list (isInbox = true)
/// is seeded on first launch and cannot be deleted or renamed.
@Model
final class TaskList {

    // MARK: - Attributes

    @Attribute(.unique) var id: UUID
    var name: String
    /// Hex color string (e.g. "#4A90E2"). Nil uses the default accent color.
    var color: String?
    /// SF Symbol name for the list icon (e.g. "briefcase"). Nil uses "list.bullet".
    var icon: String?
    /// Position within the home screen list. Lower = higher on screen.
    var sortOrder: Int
    /// True only for the system-generated Inbox list. Guards against deletion/rename.
    var isInbox: Bool
    var createdAt: Date

    // MARK: - Relationships

    /// All tasks that belong to this list.
    /// Cascade delete: when a list is deleted, its tasks are deleted too.
    /// In Phase 2, the delete flow will offer to move tasks to Inbox first.
    @Relationship(deleteRule: .cascade, inverse: \Task.taskList)
    var tasks: [Task] = []

    // MARK: - Init

    init(
        name: String,
        color: String? = nil,
        icon: String? = nil,
        sortOrder: Int = 0,
        isInbox: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.icon = icon
        self.sortOrder = sortOrder
        self.isInbox = isInbox
        self.createdAt = Date()
    }
}
