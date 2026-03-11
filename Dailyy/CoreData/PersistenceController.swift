import CoreData
import Foundation

/// Manages the CoreData persistent container and provides shared context
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dailyy")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData store failed to load: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Preview instance with in-memory store and sample data
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext

        // Sample expenses
        let e1 = ExpenseEntry(context: ctx)
        e1.id = UUID(); e1.amount = 12.50; e1.category = "Food"
        e1.note = "Lunch"; e1.date = Date(); e1.type = "Expense"

        let e2 = ExpenseEntry(context: ctx)
        e2.id = UUID(); e2.amount = 3000; e2.category = "Other"
        e2.note = "Monthly salary"; e2.date = Date(); e2.type = "Income"

        // Sample diary
        let d1 = DiaryEntry(context: ctx)
        d1.id = UUID(); d1.title = "A lovely morning"
        d1.content = "Had a great cup of coffee and journaled for 20 minutes."
        d1.mood = "😊"; d1.date = Date()

        // Sample friends
        var comps = DateComponents(); comps.month = 3; comps.day = 15
        let f1 = Friend(context: ctx)
        f1.id = UUID(); f1.name = "Alice"; f1.emoji = "🌸"
        f1.birthday = Calendar.current.date(from: comps)
        f1.location = "San Francisco"; f1.notes = "Loves hiking"

        // Budget goal
        let b = BudgetGoal(context: ctx)
        b.id = UUID(); b.monthlyIncome = 3000; b.useRule502030 = true
        b.month = Int16(Calendar.current.component(.month, from: Date()))
        b.year = Int16(Calendar.current.component(.year, from: Date()))

        try? ctx.save()
        return controller
    }()

    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() }
        catch { print("CoreData save error: \(error)") }
    }
}
