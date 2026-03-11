import SwiftUI
import CoreData

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var settings: SettingsViewModel
    @ObservedObject var budgetVM: BudgetViewModel
    @EnvironmentObject var localization: LocalizationManager

    @State private var incomeInput: String = ""
    @State private var appeared = false
    @State private var exportAlert = false
    @State private var hasBirthday: Bool = false
    @State private var birthdayInput: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                SectionHeader(title: localization.string("settings.profile"))
                settingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localization.string("settings.profile.birthday")).font(.appBody)
                                Text(localization.string("settings.profile.birthday.subtitle"))
                                    .font(.appCaption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if hasBirthday {
                                HStack(spacing: 8) {
                                    DatePicker("", selection: $birthdayInput, in: ...Date(), displayedComponents: .date)
                                        .labelsHidden()
                                        .onChange(of: birthdayInput) { _, d in settings.userBirthday = d }
                                    Button {
                                        hasBirthday = false
                                        settings.userBirthday = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                Button(localization.string("settings.profile.birthday.set")) {
                                    hasBirthday = true
                                    settings.userBirthday = birthdayInput
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.accentPrimary)
                            }
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localization.string("settings.profile.expectancy")).font(.appBody)
                                Text(L("settings.profile.expectancy.subtitle", settings.lifeExpectancy))
                                    .font(.appCaption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Stepper("\(settings.lifeExpectancy)", value: $settings.lifeExpectancy, in: 50...120)
                        }
                    }
                }

                SectionHeader(title: localization.string("settings.appearance"))
                settingsCard {
                    Picker(localization.string("settings.appearance.scheme"), selection: $settings.appearanceMode) {
                        Text(localization.string("settings.appearance.system")).tag("System")
                        Text(localization.string("settings.appearance.light")).tag("Light")
                        Text(localization.string("settings.appearance.dark")).tag("Dark")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settings.appearanceMode) { _, mode in
                        applyColorScheme(mode)
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localization.string("settings.language")).font(.appBody)
                            Text(localization.string("settings.language.subtitle"))
                                .font(.appCaption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Picker("", selection: Binding(
                            get: { localization.language },
                            set: { localization.setLanguage($0) }
                        )) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text("\(lang.flag) \(lang.displayName)").tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 140)
                    }
                }

                SectionHeader(title: localization.string("settings.budget"))
                settingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(localization.string("settings.budget.rule"), isOn: $settings.useRule502030)

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localization.string("settings.budget.income.title")).font(.appBody)
                                Text(localization.string("settings.budget.income.subtitle"))
                                    .font(.appCaption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                Text("$").foregroundStyle(.secondary)
                                TextField("0.00", text: $incomeInput)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                                    .font(.appMono)
                                Button(localization.string("settings.budget.income.set")) {
                                    if let v = Double(incomeInput), v > 0 {
                                        settings.monthlyIncome = v
                                        budgetVM.setMonthlyIncome(v)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.accentPrimary)
                            }
                        }

                        if settings.useRule502030 && settings.monthlyIncome > 0 {
                            Divider()
                            rule502030Preview
                        }
                    }
                }

                SectionHeader(title: localization.string("settings.notifications"))
                settingsCard {
                    Toggle(localization.string("settings.notifications.birthday"), isOn: $settings.notificationsEnabled)
                }

                SectionHeader(title: localization.string("settings.data"))
                settingsCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localization.string("settings.data.export.title")).font(.appBody)
                            Text(localization.string("settings.data.export.subtitle")).font(.appCaption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(localization.string("settings.data.export.btn")) { exportAlert = true }
                            .buttonStyle(.borderedProminent).tint(.accentPrimary)
                    }
                }

                SectionHeader(title: localization.string("settings.about"))
                settingsCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dailyy").font(.appBody).fontWeight(.semibold)
                            Text(localization.string("settings.about.tagline"))
                                .font(.appCaption).foregroundStyle(.secondary)
                            Text(localization.string("settings.about.version"))
                                .font(.appCaption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(colors: [.accentPrimary, .accentSecondary],
                                               startPoint: .top, endPoint: .bottom))
                    }
                }
            }
            .padding(28)
        }
        .alert(localization.string("settings.export.alert.title"), isPresented: $exportAlert) {
            Button(localization.string("settings.export.alert.ok")) {}
        } message: {
            Text(localization.string("settings.export.alert.message"))
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            incomeInput = settings.monthlyIncome > 0 ? String(format: "%.2f", settings.monthlyIncome) : ""
            hasBirthday = settings.userBirthday != nil
            birthdayInput = settings.userBirthday ?? Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
            withAnimation(.easeOut(duration: 0.35)) { appeared = true }
        }
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous))
            .shadow(color: AppStyle.shadowColor, radius: AppStyle.shadowRadius, x: 0, y: AppStyle.shadowY)
    }

    private var rule502030Preview: some View {
        let income = settings.monthlyIncome
        return VStack(alignment: .leading, spacing: 8) {
            Text(L("settings.budget.breakdown", income)).font(.appCaption).foregroundStyle(.secondary)
            HStack(spacing: 16) {
                BucketPill(label: L("pill.needs"), amount: income * 0.5, color: .needsColor)
                BucketPill(label: L("pill.wants"), amount: income * 0.3, color: .wantsColor)
                BucketPill(label: L("pill.savings"), amount: income * 0.2, color: .savingsColor)
            }
        }
    }

    private func applyColorScheme(_ mode: String) {
        guard let app = NSApplication.shared.windows.first else { return }
        switch mode {
        case "Light": app.appearance = NSAppearance(named: .aqua)
        case "Dark":  app.appearance = NSAppearance(named: .darkAqua)
        default:      app.appearance = nil
        }
    }
}

struct BucketPill: View {
    let label: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 10, design: .rounded)).foregroundStyle(.secondary)
            Text(amount.currencyString).font(.appCaption).fontWeight(.semibold).foregroundStyle(color)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    SettingsView(
        settings: SettingsViewModel(),
        budgetVM: BudgetViewModel(context: PersistenceController.preview.container.viewContext))
    .frame(width: 700, height: 700)
}
