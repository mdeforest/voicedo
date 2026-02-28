import SwiftUI
import SwiftData

/// Sheet for editing an existing TaskList's name, icon, and color.
/// Mutations are applied on Save; Cancel discards local state.
struct EditListSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var taskList: TaskList

    @State private var name: String
    @State private var selectedIcon: String?
    @State private var selectedColor: String?

    init(taskList: TaskList) {
        self.taskList = taskList
        _name = State(initialValue: taskList.name)
        _selectedIcon = State(initialValue: taskList.icon)
        _selectedColor = State(initialValue: taskList.color)
    }

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
            .navigationTitle("Edit List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        taskList.name = trimmed
                        taskList.icon = selectedIcon
                        taskList.color = selectedColor
                        try? modelContext.save()
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
