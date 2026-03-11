import Foundation
import CoreData
import Combine

// MARK: - Mood options
enum Mood: String, CaseIterable, Identifiable {
    case happy    = "😊"
    case excited  = "🥳"
    case calm     = "😌"
    case neutral  = "😐"
    case tired    = "😴"
    case sad      = "😢"
    case angry    = "😤"
    case loved    = "🥰"

    var id: String { rawValue }
    var label: String {
        switch self {
        case .happy:   return L("mood.happy")
        case .excited: return L("mood.excited")
        case .calm:    return L("mood.calm")
        case .neutral: return L("mood.neutral")
        case .tired:   return L("mood.tired")
        case .sad:     return L("mood.sad")
        case .angry:   return L("mood.angry")
        case .loved:   return L("mood.loved")
        }
    }
}

// MARK: - DiaryViewModel
@MainActor
class DiaryViewModel: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    @Published var searchText: String = ""
    @Published var selectedDate: Date = Date()

    private let ctx: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.ctx = context
        fetchAll()
    }

    func fetchAll() {
        let req: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        entries = (try? ctx.fetch(req)) ?? []
    }

    var filteredEntries: [DiaryEntry] {
        if searchText.isEmpty { return entries }
        return entries.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.content ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Entry for a given calendar date
    func entry(for date: Date) -> DiaryEntry? {
        let cal = Calendar.current
        return entries.first { e in
            guard let d = e.date else { return false }
            return cal.isDate(d, inSameDayAs: date)
        }
    }

    var todayEntry: DiaryEntry? { entry(for: Date()) }

    // MARK: CRUD
    func addEntry(title: String, content: String, mood: String, date: Date) {
        let e = DiaryEntry(context: ctx)
        e.id = UUID(); e.title = title; e.content = content
        e.mood = mood; e.date = date
        save()
    }

    func updateEntry(_ entry: DiaryEntry, title: String, content: String, mood: String) {
        entry.title = title; entry.content = content; entry.mood = mood
        save()
    }

    func deleteEntry(_ entry: DiaryEntry) {
        ctx.delete(entry)
        save()
    }

    private func save() {
        PersistenceController.shared.save()
        fetchAll()
    }
}
