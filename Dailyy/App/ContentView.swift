import SwiftUI

// MARK: - Root content view with sidebar + main area
struct ContentView: View {
    @StateObject private var budgetVM: BudgetViewModel
    @StateObject private var diaryVM: DiaryViewModel
    @StateObject private var friendsVM: FriendsViewModel
    @StateObject private var settings = SettingsViewModel()

    @State private var selectedSection: AppSection = .dashboard

    init(context: NSManagedObjectContext) {
        _budgetVM  = StateObject(wrappedValue: BudgetViewModel(context: context))
        _diaryVM   = StateObject(wrappedValue: DiaryViewModel(context: context))
        _friendsVM = StateObject(wrappedValue: FriendsViewModel(context: context))
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(selected: $selectedSection)

            Divider()

            // Main content
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, idealWidth: 1000, maxWidth: .infinity, minHeight: 600, idealHeight: 800, maxHeight: .infinity)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch selectedSection {
        case .dashboard:
            DashboardView(budgetVM: budgetVM, diaryVM: diaryVM, friendsVM: friendsVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .budget:
            BudgetView(vm: budgetVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .diary:
            DiaryView(vm: diaryVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .friends:
            FriendsView(vm: friendsVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .lifespan:
            LifeSpanView(settings: settings)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .settings:
            SettingsView(settings: settings, budgetVM: budgetVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        }
    }
}

import CoreData

#Preview {
    ContentView(context: PersistenceController.preview.container.viewContext)
}
