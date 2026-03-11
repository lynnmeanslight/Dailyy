import Foundation
import Combine

// MARK: - App-wide settings
class SettingsViewModel: ObservableObject {
    @Published var monthlyIncome: Double {
        didSet { UserDefaults.standard.set(monthlyIncome, forKey: "monthlyIncome") }
    }
    @Published var useRule502030: Bool {
        didSet { UserDefaults.standard.set(useRule502030, forKey: "useRule502030") }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }
    @Published var appearanceMode: String {
        didSet { UserDefaults.standard.set(appearanceMode, forKey: "appearanceMode") }
    }
    @Published var userBirthday: Date? {
        didSet {
            if let d = userBirthday {
                UserDefaults.standard.set(d.timeIntervalSince1970, forKey: "userBirthday")
            } else {
                UserDefaults.standard.removeObject(forKey: "userBirthday")
            }
        }
    }
    @Published var lifeExpectancy: Int {
        didSet { UserDefaults.standard.set(lifeExpectancy, forKey: "lifeExpectancy") }
    }

    init() {
        monthlyIncome      = UserDefaults.standard.double(forKey: "monthlyIncome")
        useRule502030      = UserDefaults.standard.object(forKey: "useRule502030") as? Bool ?? true
        notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        appearanceMode     = UserDefaults.standard.string(forKey: "appearanceMode") ?? "System"
        let bdTs = UserDefaults.standard.double(forKey: "userBirthday")
        userBirthday = bdTs > 0 ? Date(timeIntervalSince1970: bdTs) : nil
        let le = UserDefaults.standard.integer(forKey: "lifeExpectancy")
        lifeExpectancy = le > 0 ? le : 80
    }
}

// MARK: - Navigation state
enum AppSection: String, CaseIterable, Identifiable {
    case dashboard  = "Dashboard"
    case budget     = "Budget"
    case diary      = "Diary"
    case friends    = "Friends"
    case lifespan   = "LifeSpan"
    case settings   = "Settings"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .dashboard: return L("section.dashboard")
        case .budget:    return L("section.budget")
        case .diary:     return L("section.diary")
        case .friends:   return L("section.friends")
        case .lifespan:  return L("section.lifespan")
        case .settings:  return L("section.settings")
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "sun.max.fill"
        case .budget:    return "leaf.fill"
        case .diary:     return "book.fill"
        case .friends:   return "person.2.fill"
        case .lifespan:  return "hourglass"
        case .settings:  return "gearshape.fill"
        }
    }

    var color: Color { AppSection.colors[self] ?? .accentPrimary }

    private static let colors: [AppSection: Color] = [
        .dashboard: .pastelGreen,
        .budget:    .pastelGreen,
        .diary:     .pastelBlue,
        .friends:   .pastelPink,
        .lifespan:  .pastelPurple,
        .settings:  .pastelPeach
    ]
}

import SwiftUI
