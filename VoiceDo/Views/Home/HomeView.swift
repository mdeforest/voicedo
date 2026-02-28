import SwiftUI
import SwiftData

/// The Home screen — a bento-style card grid of all TaskLists.
///
/// Layout:
/// - Large bold "VoiceDo" header with plus button (opens AddListSheet)
/// - Inbox as a full-width hero card pinned at the top
/// - User-created lists in a 2-column pastel card grid
///
/// The system nav bar is hidden so the header reads as part of the scroll content.
struct HomeView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var listPendingEdit: TaskList? = nil
    @State private var isVoiceInputPresented = false

    @Query(sort: \TaskList.sortOrder) private var taskLists: [TaskList]

    private var inboxList: TaskList? {
        taskLists.first(where: { $0.isInbox })
    }

    private var userLists: [TaskList] {
        taskLists.filter { !$0.isInbox }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if taskLists.isEmpty {
                    // Safety net — Inbox is seeded at launch, so this is rarely visible.
                    EmptyStateView(
                        systemImage: "tray",
                        title: "No lists yet",
                        message: "Relaunch the app to create your Inbox."
                    )
                } else {
                    scrollContent
                }

                // Floating mic button — bottom-center, above home indicator
                VStack {
                    Spacer()
                    MicButton(isPresented: $isVoiceInputPresented)
                        .padding(.bottom, 24)
                }
            }
            // Hide the system nav bar — the header lives inside the scroll view.
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isVoiceInputPresented) {
                VoiceInputView(isPresented: $isVoiceInputPresented)
            }
            .sheet(isPresented: $viewModel.isAddListPresented) {
                AddListSheet(viewModel: viewModel, allLists: taskLists)
            }
            .sheet(item: $listPendingEdit) { list in
                EditListSheet(taskList: list)
            }
            .alert("Delete \"\(viewModel.listPendingDeletion?.name ?? "")\"?", isPresented: $viewModel.isDeleteListAlertPresented) {
                Button("Move Tasks to Inbox", role: .none) {
                    if let list = viewModel.listPendingDeletion {
                        viewModel.deleteList(list, moveTasksToInbox: true, inbox: inboxList, context: modelContext)
                    }
                }
                Button("Delete Tasks Too", role: .destructive) {
                    if let list = viewModel.listPendingDeletion {
                        viewModel.deleteList(list, moveTasksToInbox: false, inbox: inboxList, context: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {
                    viewModel.listPendingDeletion = nil
                }
            } message: {
                Text("This list has \(viewModel.listPendingDeletion?.tasks.count ?? 0) task(s). What should happen to them?")
            }
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection

                // Inbox — always full width at the top
                if let inbox = inboxList {
                    NavigationLink(destination: ListDetailView(taskList: inbox)) {
                        TaskListCard(taskList: inbox, isHero: true)
                    }
                    .buttonStyle(.plain)
                }

                // User-created lists — 2-column grid
                if !userLists.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Lists")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Array(userLists.enumerated()), id: \.element.id) { index, list in
                                NavigationLink(destination: ListDetailView(taskList: list)) {
                                    TaskListCard(taskList: list, colorIndex: index)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        listPendingEdit = list
                                    } label: {
                                        Label("Edit List", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        viewModel.listPendingDeletion = list
                                        viewModel.isDeleteListAlertPresented = true
                                    } label: {
                                        Label("Delete List", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("VoiceDo")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                Text("What needs doing today?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.isAddListPresented = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.7), in: Circle())
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Add List Sheet

private struct AddListSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let viewModel: HomeViewModel
    let allLists: [TaskList]

    @State private var name = ""
    @State private var selectedIcon: String? = "list.bullet"
    @State private var selectedColor: String? = nil

    private let iconOptions: [String] = [
        "list.bullet", "star", "heart", "briefcase", "house",
        "cart", "book", "dumbbell", "fork.knife", "car",
        "airplane", "music.note", "gamecontroller", "camera", "leaf"
    ]

    private let colorOptions: [(label: String, hex: String?)] = [
        ("None", nil),
        ("Lavender", "CBC3F0"),
        ("Yellow", "F5E49E"),
        ("Peach", "F5C9B8"),
        ("Mint", "BAE8D4"),
        ("Sky", "B8D8F5"),
    ]

    private let iconColumns = Array(repeating: GridItem(.flexible()), count: 5)
    private let colorColumns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("List name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: iconColumns, spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            iconCell(icon)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Color") {
                    LazyVGrid(columns: colorColumns, spacing: 12) {
                        ForEach(colorOptions, id: \.label) { option in
                            colorCell(option)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.createList(
                            name: name,
                            color: selectedColor,
                            icon: selectedIcon,
                            context: modelContext,
                            allLists: allLists
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func iconCell(_ icon: String) -> some View {
        let isSelected = selectedIcon == icon
        return Button {
            selectedIcon = icon
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }

    private func colorCell(_ option: (label: String, hex: String?)) -> some View {
        let isSelected = selectedColor == option.hex
        return Button {
            selectedColor = option.hex
        } label: {
            ZStack {
                Circle()
                    .fill(option.hex.map { Color(hex: $0) } ?? Color.secondary.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().strokeBorder(isSelected ? Color.primary : Color.clear, lineWidth: 2)
                    )
                if option.hex == nil {
                    Image(systemName: "slash.circle")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [TaskList.self, Task.self], inMemory: true)
}
