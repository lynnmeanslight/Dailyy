import Foundation
import CoreData
import UserNotifications
import Combine

// MARK: - FriendsViewModel
@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var searchText: String = ""

    private let ctx: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.ctx = context
        fetchAll()
    }

    func fetchAll() {
        let req: NSFetchRequest<Friend> = Friend.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        friends = (try? ctx.fetch(req)) ?? []
    }

    var filteredFriends: [Friend] {
        if searchText.isEmpty { return friends }
        return friends.filter { ($0.name ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    /// Friends with upcoming birthdays in next 30 days, sorted by soonest
    var upcomingBirthdays: [Friend] {
        friends.filter {
            guard let b = $0.birthday else { return false }
            let days = b.daysUntilBirthday()
            return days <= 30
        }.sorted {
            ($0.birthday?.daysUntilBirthday() ?? 999) < ($1.birthday?.daysUntilBirthday() ?? 999)
        }
    }

    // MARK: CRUD
    func addFriend(name: String, birthday: Date?, location: String, notes: String, emoji: String) {
        let f = Friend(context: ctx)
        f.id = UUID(); f.name = name; f.birthday = birthday
        f.location = location; f.notes = notes; f.emoji = emoji
        save()
        if let b = birthday { scheduleBirthdayNotification(for: f, birthday: b) }
    }

    func updateFriend(_ friend: Friend, name: String, birthday: Date?, location: String, notes: String, emoji: String) {
        friend.name = name; friend.birthday = birthday
        friend.location = location; friend.notes = notes; friend.emoji = emoji
        save()
        if let b = birthday { scheduleBirthdayNotification(for: friend, birthday: b) }
    }

    func deleteFriend(_ friend: Friend) {
        ctx.delete(friend)
        save()
    }

    // MARK: Notifications
    func scheduleBirthdayNotification(for friend: Friend, birthday: Date) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "🎂 Birthday Reminder!"
            content.body = "Today is \(friend.name ?? "your friend")'s birthday! Don't forget to wish them!"
            content.sound = .default

            var triggerComps = Calendar.current.dateComponents([.month, .day], from: birthday)
            triggerComps.hour = 9; triggerComps.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComps, repeats: true)

            let req = UNNotificationRequest(
                identifier: "birthday-\(friend.id?.uuidString ?? UUID().uuidString)",
                content: content, trigger: trigger)
            center.add(req)
        }
    }

    private func save() {
        PersistenceController.shared.save()
        fetchAll()
    }
}
