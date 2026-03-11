import Foundation
import Combine

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case myanmar = "my"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .myanmar: return "မြန်မာ"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .myanmar: return "🇲🇲"
        }
    }
}

// MARK: - Localization Manager
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published private(set) var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
            bundle = Self.bundle(for: language)
        }
    }

    private(set) var bundle: Bundle

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        let lang = AppLanguage(rawValue: saved) ?? .english
        self.language = lang
        self.bundle = Self.bundle(for: lang)
    }

    func setLanguage(_ lang: AppLanguage) {
        language = lang
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let b = Bundle(path: path)
        else {
            return Bundle.main
        }
        return b
    }

    func string(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }

    func string(_ key: String, _ args: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: key, table: "Localizable")
        return String(format: format, arguments: args)
    }
}

// MARK: - Convenience shorthand
func L(_ key: String) -> String {
    LocalizationManager.shared.string(key)
}

func L(_ key: String, _ args: CVarArg...) -> String {
    let format = LocalizationManager.shared.bundle.localizedString(forKey: key, value: key, table: "Localizable")
    return String(format: format, arguments: args)
}
