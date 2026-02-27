import Foundation
import UserNotifications

/// Manages local notification scheduling and cancellation for task reminders.
///
/// Phase 1: Stub.
/// Phase 5: Full implementation — schedules UNCalendarNotificationTrigger on tasks with
///          reminderDate set, cancels notifications on task completion or reminder removal,
///          uses encouraging copy (no guilt language — see PRD Section 6.3).
///
/// Note: Permission is requested on first voice input, NOT at app launch (PRD Section 6.3).
final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permissions

    /// Requests notification authorization from the user.
    /// Call this the first time the user completes a voice input, not at launch.
    func requestPermission() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )
    }

    // MARK: - Phase 5 TODOs
    //
    // - scheduleReminder(for task: Task) throws
    //   → Creates UNMutableNotificationContent with encouraging copy
    //   → Schedules UNCalendarNotificationTrigger at task.reminderDate
    //   → Stores the notification identifier on the task
    //
    // - cancelReminder(for task: Task)
    //   → Removes pending notification by stored identifier
    //
    // - rescheduleIfPast(task: Task)
    //   → If reminderDate is in the past, schedule for same time next day
    //
    // - Notification copy examples (PRD):
    //   → "Whenever you're ready: \(task.title)"
    //   → "Still on your list: \(task.title)"
}
