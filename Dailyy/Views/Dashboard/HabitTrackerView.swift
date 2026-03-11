import SwiftUI

struct HabitTrackerView: View {
    @StateObject private var habitManager = HabitManager()
    @State private var showingAddForm = false
    @State private var newHabitTitle = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Daily Habits")
                Spacer()
                Button(action: { showingAddForm.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if showingAddForm {
                HStack {
                    TextField("New habit...", text: $newHabitTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addNewHabit()
                        }
                    
                    Button("Add") {
                        addNewHabit()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentPrimary)
                    .disabled(newHabitTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    
                    Button("Cancel") {
                        withAnimation {
                            showingAddForm = false
                            newHabitTitle = ""
                        }
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.bottom, 8)
                .transition(.opacity)
            }
            
            if habitManager.habits.isEmpty {
                Text("No habits yet.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(habitManager.habits) { habit in
                        HabitRow(habit: habit) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                habitManager.toggleHabit(habit)
                            }
                        } onDelete: {
                            if let idx = habitManager.habits.firstIndex(of: habit) {
                                habitManager.deleteHabit(at: IndexSet(integer: idx))
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private func addNewHabit() {
        let trimmed = newHabitTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            habitManager.addHabit(title: trimmed)
            newHabitTitle = ""
            showingAddForm = false
        }
    }
}

struct HabitRow: View {
    let habit: DailyHabit
    let action: () -> Void
    let onDelete: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: action) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(habit.isCompleted ? Color.accentPrimary : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(habit.title)
                .font(.appBody)
                .strikethrough(habit.isCompleted)
                .foregroundStyle(habit.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
