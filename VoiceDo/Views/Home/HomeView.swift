import SwiftUI
import SwiftData

/// The Home screen — shows all TaskLists with their task counts.
/// Inbox is always pinned at the top. User-created lists appear below.
///
/// Phase 2 will add: list creation (+), delete, reorder, and the floating mic button.
struct HomeView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()

    /// All lists, ordered by sortOrder (Inbox is sortOrder: 0).
    @Query(sort: \TaskList.sortOrder) private var taskLists: [TaskList]

    private var inboxList: TaskList? {
        taskLists.first(where: { $0.isInbox })
    }

    private var userLists: [TaskList] {
        taskLists.filter { !$0.isInbox }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if taskLists.isEmpty {
                    // Shouldn't normally be seen — Inbox is seeded at launch.
                    // Shown as a safety net if seeding fails.
                    ContentUnavailableView(
                        "No Lists",
                        systemImage: "list.bullet",
                        description: Text("Relaunch the app to set up your Inbox.")
                    )
                } else {
                    listContent
                }
            }
            .navigationTitle("VoiceDo")
            .toolbar {
                // Phase 2: Add list creation button here
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isAddListPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(true)  // Enabled in Phase 2
                }
            }
        }
    }

    // MARK: - Subviews

    private var listContent: some View {
        List {
            // Inbox — always at the top, outside any section header
            if let inbox = inboxList {
                Section {
                    NavigationLink(destination: ListDetailView(taskList: inbox)) {
                        TaskListRow(taskList: inbox)
                    }
                }
            }

            // User-created lists
            if !userLists.isEmpty {
                Section("My Lists") {
                    ForEach(userLists) { list in
                        NavigationLink(destination: ListDetailView(taskList: list)) {
                            TaskListRow(taskList: list)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskList.self, Task.self, configurations: config)

    // Seed preview data
    let inbox = TaskList(name: "Inbox", icon: "tray", sortOrder: 0, isInbox: true)
    let work = TaskList(name: "Work", icon: "briefcase", sortOrder: 1)
    let errands = TaskList(name: "Errands", icon: "cart", sortOrder: 2)

    // Add a couple of tasks to make the counts non-zero
    let task1 = Task(title: "Review PR", taskList: inbox)
    let task2 = Task(title: "Buy groceries", taskList: errands)
    let task3 = Task(title: "Pick up prescription", taskList: errands)

    container.mainContext.insert(inbox)
    container.mainContext.insert(work)
    container.mainContext.insert(errands)
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)
    container.mainContext.insert(task3)

    return HomeView()
        .modelContainer(container)
}
