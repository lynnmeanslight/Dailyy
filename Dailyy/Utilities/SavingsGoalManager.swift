import Foundation
import Combine
import SwiftUI

struct SavingsGoal: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double = 0
    var icon: String = "Star" // Emoji or short symbol
    
    var progress: Double {
        if targetAmount == 0 { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
}

class SavingsGoalManager: ObservableObject {
    @AppStorage("savings_goals") private var goalsData: Data = Data()
    
    @Published var goals: [SavingsGoal] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        load()
    }
    
    private func load() {
        if let decoded = try? JSONDecoder().decode([SavingsGoal].self, from: goalsData) {
            self.goals = decoded
        } else {
            self.goals = [
                SavingsGoal(title: "New MacBook", targetAmount: 1500, currentAmount: 300, icon: "💻"),
                SavingsGoal(title: "Japan Trip", targetAmount: 3000, currentAmount: 1200, icon: "✈️")
            ]
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(goals) {
            goalsData = encoded
        }
    }
    
    func addGoal(title: String, target: Double, icon: String) {
        goals.append(SavingsGoal(title: title, targetAmount: target, currentAmount: 0, icon: icon))
    }
    
    func addFunds(to goal: SavingsGoal, amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].currentAmount += amount
        }
    }
    
    func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
}
