import Foundation
import Combine
import SwiftUI

struct DailyHabit: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var lastCompletedDate: Date? = nil
    
    // Automatically reset completion if it wasn't completed today
    mutating func checkReset() {
        if isCompleted {
            if let date = lastCompletedDate, !Calendar.current.isDateInToday(date) {
                isCompleted = false
                lastCompletedDate = nil
            }
        }
    }
}

class HabitManager: ObservableObject {
    @AppStorage("daily_habits") private var habitsData: Data = Data()
    
    @Published var habits: [DailyHabit] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        load()
        resetIfNeeded()
    }
    
    private func load() {
        if let decoded = try? JSONDecoder().decode([DailyHabit].self, from: habitsData) {
            self.habits = decoded
        } else {
            // Default cozy habits
            self.habits = [
                DailyHabit(title: "Drink Water"),
                DailyHabit(title: "Read 10 pages"),
                DailyHabit(title: "Go for a walk")
            ]
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(habits) {
            habitsData = encoded
        }
    }
    
    private func resetIfNeeded() {
        var didReset = false
        for i in 0..<habits.count {
            let wasCompleted = habits[i].isCompleted
            habits[i].checkReset()
            if wasCompleted && !habits[i].isCompleted {
                didReset = true
            }
        }
        if didReset { save() }
    }
    
    func toggleHabit(_ habit: DailyHabit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
            if habits[index].isCompleted {
                habits[index].lastCompletedDate = Date()
            } else {
                habits[index].lastCompletedDate = nil
            }
        }
    }
    
    func addHabit(title: String) {
        habits.append(DailyHabit(title: title))
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }
}
