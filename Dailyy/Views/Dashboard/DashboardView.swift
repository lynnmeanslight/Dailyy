import SwiftUI

// MARK: - Dashboard
struct DashboardView: View {
    @ObservedObject var budgetVM: BudgetViewModel
    @ObservedObject var diaryVM: DiaryViewModel
    @ObservedObject var friendsVM: FriendsViewModel
    @EnvironmentObject var localization: LocalizationManager

    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Greeting header
                greetingHeader

                // Top stats row
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(title: localization.string("dashboard.spending.today"),
                             value: todaySpending.currencyString,
                             icon: "creditcard.fill",
                             color: .pastelPeach)
                    StatCard(title: localization.string("dashboard.balance.monthly"),
                             value: budgetVM.balance.currencyString,
                             icon: "banknote.fill",
                             color: .pastelGreen)
                    StatCard(title: localization.string("dashboard.birthdays.upcoming"),
                             value: "\(friendsVM.upcomingBirthdays.count)",
                             icon: "gift.fill",
                             color: .pastelPink)
                }

                // Finance status
                financeStatusCard

                // Latest diary
                if let entry = diaryVM.todayEntry {
                    latestDiaryCard(entry: entry)
                }

                // Mini Habit Tracker
                HabitTrackerView()

                // Upcoming birthdays strip
                if !friendsVM.upcomingBirthdays.isEmpty {
                    upcomingBirthdaysStrip
                }
            }
            .padding(28)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    // MARK: Sub-views
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greetingText)
                .font(.appTitle)
            Text(Date().dayMonthYear)
                .font(.appBody)
                .foregroundStyle(.secondary)
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return localization.string("greeting.morning")
        case 12..<17: return localization.string("greeting.afternoon")
        default:      return localization.string("greeting.evening")
        }
    }

    private var financeStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: localization.string("dashboard.overview"))

            BucketRow(label: localization.string("bucket.needs"),
                      spent: budgetVM.needsSpent,
                      budget: budgetVM.needsBudget,
                      color: .needsColor)

            BucketRow(label: localization.string("bucket.wants"),
                      spent: budgetVM.wantsSpent,
                      budget: budgetVM.wantsBudget,
                      color: .wantsColor)

            BucketRow(label: localization.string("bucket.savings"),
                      spent: budgetVM.savingsProgress,
                      budget: budgetVM.savingsBudget,
                      color: .savingsColor,
                      isSavings: true)
        }
        .cardStyle()
    }

    private func latestDiaryCard(entry: DiaryEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: localization.string("dashboard.journal.today"))
            HStack(spacing: 12) {
                Text(entry.mood ?? "📓")
                    .font(.system(size: 36))
                VStack(alignment: .leading, spacing: 4) {
                    if let date = entry.date {
                        Text(date.dayMonthYear)
                            .font(.appBody)
                            .fontWeight(.semibold)
                    }
                    Text(entry.content ?? "")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .cardStyle()
    }

    private var upcomingBirthdaysStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localization.string("dashboard.birthdays.strip"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(friendsVM.upcomingBirthdays) { friend in
                        BirthdayMiniCard(friend: friend)
                    }
                }
            }
        }
    }

    private var todaySpending: Double {
        budgetVM.entries.filter { e in
            guard let d = e.date else { return false }
            return Calendar.current.isDateInToday(d) && e.type == "Expense"
        }.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Bucket Row
struct BucketRow: View {
    let label: String
    let spent: Double
    let budget: Double
    let color: Color
    var isSavings: Bool = false

    var ratio: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.appCaption).foregroundStyle(.secondary)
                Spacer()
                if isSavings {
                    Text(L("bucket.saved", spent.currencyString))
                        .font(.appCaption).foregroundStyle(color)
                } else {
                    Text("\(spent.currencyString) / \(budget.currencyString)")
                        .font(.appCaption).foregroundStyle(.secondary)
                }
            }
            AnimatedProgressBar(value: ratio, color: color, height: 10)
        }
    }
}

// MARK: - Birthday mini card
struct BirthdayMiniCard: View {
    let friend: Friend
    @State private var sparkle = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.pastelYellow)
                    .frame(width: 52, height: 52)
                Text(friend.emoji ?? "👤")
                    .font(.system(size: 26))
                if friend.birthday?.isSameDayOfYear == true {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(.yellow)
                        .offset(x: 18, y: -18)
                        .scaleEffect(sparkle ? 1.4 : 0.8)
                        .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: sparkle)
                        .onAppear { sparkle = true }
                }
            }
            Text(friend.name ?? "")
                .font(.appCaption)
                .fontWeight(.semibold)
                .lineLimit(1)
            Text(daysText)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .cardStyle(padding: 0)
        .frame(width: 90)
    }

    var daysText: String {
        guard let b = friend.birthday else { return "" }
        let days = b.daysUntilBirthday()
        if days == 0 { return L("friends.birthday.minicard.today") }
        return days == 1 ? L("friends.birthday.minicard.in", days) : L("friends.birthday.minicard.in.plural", days)
    }
}

#Preview {
    DashboardView(
        budgetVM: BudgetViewModel(context: PersistenceController.preview.container.viewContext),
        diaryVM: DiaryViewModel(context: PersistenceController.preview.container.viewContext),
        friendsVM: FriendsViewModel(context: PersistenceController.preview.container.viewContext))
    .frame(width: 800, height: 600)
}
