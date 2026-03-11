import SwiftUI

struct SavingsGoalView: View {
    @StateObject private var goalManager = SavingsGoalManager()
    @State private var showAddSheet = false
    
    // Add form states
    @State private var newTitle = ""
    @State private var newTarget: String = ""
    @State private var newIcon = "🌟"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Savings Goals")
                Spacer()
                Button(action: { showAddSheet.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showAddSheet, arrowEdge: .bottom) {
                    addGoalForm
                }
            }
            
            if goalManager.goals.isEmpty {
                Text("No goals yet. Start saving!")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(goalManager.goals) { goal in
                        GoalRow(goal: goal) { amount in
                            goalManager.addFunds(to: goal, amount: amount)
                        } onDelete: {
                            if let idx = goalManager.goals.firstIndex(of: goal) {
                                goalManager.deleteGoal(at: IndexSet(integer: idx))
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var addGoalForm: some View {
        VStack(spacing: 12) {
            Text("New Savings Goal")
                .font(.appBody).fontWeight(.semibold)
            
            TextField("Icon (e.g. 🏡)", text: $newIcon)
                .textFieldStyle(.roundedBorder)
            
            TextField("Goal Name...", text: $newTitle)
                .textFieldStyle(.roundedBorder)
            
            TextField("Target Amount...", text: $newTarget)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel") {
                    showAddSheet = false
                }
                .buttonStyle(.borderless)
                
                Button("Add") {
                    if let target = Double(newTarget), !newTitle.isEmpty {
                        goalManager.addGoal(title: newTitle, target: target, icon: newIcon)
                        newTitle = ""
                        newTarget = ""
                        newIcon = "🌟"
                        showAddSheet = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentPrimary)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(width: 250)
    }
}

struct GoalRow: View {
    let goal: SavingsGoal
    let onAddFunds: (Double) -> Void
    let onDelete: () -> Void
    
    @State private var showingAddFunds = false
    @State private var fundAmount = ""
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.icon)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.appBody).fontWeight(.medium)
                    Text("\(goal.currentAmount.currencyString) / \(goal.targetAmount.currencyString)")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isHovering {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
                }
                
                Button(action: { showingAddFunds.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentPrimary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingAddFunds, arrowEdge: .leading) {
                    addFundsPopover
                }
            }
            
            AnimatedProgressBar(value: goal.progress, color: Color.savingsColor, height: 8)
        }
        .padding(.vertical, 4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    private var addFundsPopover: some View {
        VStack(spacing: 8) {
            Text("Add Funds")
                .font(.appCaption).fontWeight(.medium)
            HStack {
                TextField("Amount...", text: $fundAmount)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                
                Button("Add") {
                    if let amt = Double(fundAmount) {
                        onAddFunds(amt)
                        showingAddFunds = false
                        fundAmount = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentPrimary)
            }
        }
        .padding()
    }
}
