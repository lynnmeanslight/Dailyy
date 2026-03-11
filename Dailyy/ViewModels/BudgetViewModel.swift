import Foundation
import CoreData
import Combine

// MARK: - Category enum
enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case entertainment = "Entertainment"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food:          return "fork.knife"
        case .transport:     return "car.fill"
        case .shopping:      return "bag.fill"
        case .bills:         return "doc.text.fill"
        case .entertainment: return "gamecontroller.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }

    // 50/30/20 bucket
    var bucket: BudgetBucket {
        switch self {
        case .food, .transport, .bills: return .needs
        case .shopping, .entertainment: return .wants
        case .other:                    return .needs
        }
    }
}

enum BudgetBucket: String {
    case needs = "Needs"
    case wants = "Wants"
    case savings = "Savings"
}

enum TransactionType: String, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    var id: String { rawValue }
}

// MARK: - BudgetViewModel
@MainActor
class BudgetViewModel: ObservableObject {
    @Published var entries: [ExpenseEntry] = []
    @Published var budgetGoal: BudgetGoal?
    @Published var selectedMonth: Date = Date()

    private let ctx: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.ctx = context
        fetchAll()
    }

    // MARK: Fetch
    func fetchAll() {
        fetchEntries()
        fetchBudgetGoal()
    }

    func fetchEntries() {
        let req: NSFetchRequest<ExpenseEntry> = ExpenseEntry.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        entries = (try? ctx.fetch(req)) ?? []
    }

    func fetchBudgetGoal() {
        let req: NSFetchRequest<BudgetGoal> = BudgetGoal.fetchRequest()
        let all = (try? ctx.fetch(req)) ?? []
        let cal = Calendar.current
        let m = cal.component(.month, from: selectedMonth)
        let y = cal.component(.year, from: selectedMonth)
        budgetGoal = all.first(where: { Int($0.month) == m && Int($0.year) == y })
            ?? all.first
    }

    // MARK: Computed for current month
    var monthEntries: [ExpenseEntry] {
        let cal = Calendar.current
        let m = cal.component(.month, from: selectedMonth)
        let y = cal.component(.year, from: selectedMonth)
        return entries.filter {
            guard let d = $0.date else { return false }
            return cal.component(.month, from: d) == m && cal.component(.year, from: d) == y
        }
    }

    var monthlyIncome: Double {
        monthEntries.filter { $0.type == "Income" }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        monthEntries.filter { $0.type == "Expense" }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double { monthlyIncome - totalExpenses }

    // 50/30/20 base income: prefer set goal, else actual income
    var baseIncome: Double {
        if let g = budgetGoal, g.monthlyIncome > 0 { return g.monthlyIncome }
        return monthlyIncome
    }

    var needsBudget: Double  { baseIncome * 0.50 }
    var wantsBudget: Double  { baseIncome * 0.30 }
    var savingsBudget: Double { baseIncome * 0.20 }

    var needsSpent: Double {
        monthEntries.filter { $0.type == "Expense" && ExpenseCategory(rawValue: $0.category ?? "")?.bucket == .needs }
                    .reduce(0) { $0 + $1.amount }
    }

    var wantsSpent: Double {
        monthEntries.filter { $0.type == "Expense" && ExpenseCategory(rawValue: $0.category ?? "")?.bucket == .wants }
                    .reduce(0) { $0 + $1.amount }
    }

    var savingsProgress: Double {
        max(0, baseIncome - totalExpenses)
    }

    // Category breakdown for pie chart
    var categoryTotals: [(category: String, amount: Double)] {
        var dict: [String: Double] = [:]
        monthEntries.filter { $0.type == "Expense" }.forEach {
            dict[$0.category ?? "Other", default: 0] += $0.amount
        }
        return dict.map { (category: $0.key, amount: $0.value) }
                   .sorted { $0.amount > $1.amount }
    }

    // Daily spending for bar chart (last 7 days)
    var dailySpending: [(date: Date, amount: Double)] {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset -> (Date, Double)? in
            guard let d = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let total = entries.filter {
                guard let ed = $0.date else { return false }
                return cal.isDate(ed, inSameDayAs: d) && $0.type == "Expense"
            }.reduce(0) { $0 + $1.amount }
            return (d, total)
        }.reversed()
    }

    // MARK: CRUD
    func addEntry(amount: Double, category: String, note: String, date: Date, type: String) {
        let e = ExpenseEntry(context: ctx)
        e.id = UUID(); e.amount = amount; e.category = category
        e.note = note; e.date = date; e.type = type
        save()
    }

    func deleteEntry(_ entry: ExpenseEntry) {
        ctx.delete(entry)
        save()
    }

    func setMonthlyIncome(_ income: Double) {
        let cal = Calendar.current
        let m = Int16(cal.component(.month, from: selectedMonth))
        let y = Int16(cal.component(.year, from: selectedMonth))
        if let g = budgetGoal {
            g.monthlyIncome = income
        } else {
            let g = BudgetGoal(context: ctx)
            g.id = UUID(); g.monthlyIncome = income
            g.useRule502030 = true; g.month = m; g.year = y
            budgetGoal = g
        }
        save()
    }

    private func save() {
        PersistenceController.shared.save()
        fetchAll()
    }
}
