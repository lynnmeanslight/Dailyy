import SwiftUI

// MARK: - Life Span View
struct LifeSpanView: View {
    @ObservedObject var settings: SettingsViewModel
    @EnvironmentObject var localization: LocalizationManager

    @State private var appeared = false

    // MARK: - Computed values
    private var calendar: Calendar { Calendar(identifier: .gregorian) }
    private var birthday: Date? { settings.userBirthday }
    private var lifeExpectancy: Int { settings.lifeExpectancy }

    private var ageComponents: DateComponents {
        guard let bday = birthday else { return DateComponents() }
        return calendar.dateComponents([.year, .month, .day], from: bday, to: Date())
    }

    private var ageYears: Int { ageComponents.year ?? 0 }

    private var totalWeeks: Int { lifeExpectancy * 52 }

    private var weeksLived: Int {
        guard let bday = birthday else { return 0 }
        let days = calendar.dateComponents([.day], from: bday, to: Date()).day ?? 0
        return min(max(0, days / 7), totalWeeks)
    }

    private var weeksRemaining: Int { max(0, totalWeeks - weeksLived) }
    private var daysRemaining: Int { weeksRemaining * 7 }
    private var percentLived: Double { totalWeeks > 0 ? Double(weeksLived) / Double(totalWeeks) : 0 }

    private func fmt(_ n: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: n as NSNumber) ?? "\(n)"
    }

    // MARK: - Body
    var body: some View {
        Group {
            if birthday == nil {
                noBirthdayPrompt
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        pageHeader
                        statsRow
                        weekGridCard
                        inspirationSection
                    }
                    .padding(28)
                }
                .background(Color(NSColor.windowBackgroundColor))
                .opacity(appeared ? 1 : 0)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.4)) { appeared = true }
                }
            }
        }
    }

    // MARK: - No birthday prompt
    private var noBirthdayPrompt: some View {
        VStack(spacing: 24) {
            Image(systemName: "hourglass")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentPrimary, .accentSecondary],
                        startPoint: .top, endPoint: .bottom))

            Text(localization.string("lifespan.setup.title"))
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Text(localization.string("lifespan.setup.subtitle"))
                .font(.appBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 340)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header
    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                Text(localization.string("lifespan.title"))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
            Text(L("lifespan.age.subtitle", ageYears, lifeExpectancy))
                .font(.appBody)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Stats row
    private var statsRow: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()),
                      GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16) {
            StatCard(title: localization.string("lifespan.stat.age"),
                     value: "\(ageYears)",
                     icon: "person.fill",
                     color: .pastelPurple)
            StatCard(title: localization.string("lifespan.stat.weeks.lived"),
                     value: fmt(weeksLived),
                     icon: "checkmark.seal.fill",
                     color: .pastelGreen)
            StatCard(title: localization.string("lifespan.stat.weeks.left"),
                     value: fmt(weeksRemaining),
                     icon: "clock.fill",
                     color: .pastelPeach)
            StatCard(title: localization.string("lifespan.stat.used"),
                     value: String(format: "%.1f%%", percentLived * 100),
                     icon: "chart.pie.fill",
                     color: .pastelPink)
        }
    }

    // MARK: - Week grid card
    private var weekGridCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localization.string("lifespan.grid.title"))
                    .font(.appTitle)
                    .padding(.bottom, 6)
                Text(localization.string("lifespan.grid.subtitle"))
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }

            progressBar

            weekGrid
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous))
        .shadow(color: AppStyle.shadowColor, radius: AppStyle.shadowRadius, x: 0, y: AppStyle.shadowY)
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(min(percentLived, 1.0)), height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text(L("lifespan.progress.lived", weeksLived, totalWeeks))
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(L("lifespan.progress.remaining", weeksRemaining))
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var weekGrid: some View {
        let cols   = 52
        let rows   = lifeExpectancy
        let cell: CGFloat = 8
        let gap: CGFloat  = 2
        let totalW = CGFloat(cols) * (cell + gap) - gap
        let totalH = CGFloat(rows) * (cell + gap) - gap
        let lived  = weeksLived

        return HStack(alignment: .top, spacing: 8) {
            // Left year labels
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    if row % 10 == 0 {
                        Text("\(row)")
                            .font(.system(size: 7))
                            .foregroundStyle(.secondary)
                            .frame(height: cell + gap, alignment: .center)
                    } else {
                        Color.clear.frame(height: cell + gap)
                    }
                }
            }

            Canvas { ctx, _ in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let weekNum = row * cols + col + 1
                        let isLived   = weekNum <= lived
                        let isCurrent = weekNum == lived + 1
                        let x = CGFloat(col) * (cell + gap)
                        let y = CGFloat(row) * (cell + gap)
                        let rect = CGRect(x: x, y: y, width: cell, height: cell)
                        let path = Path(roundedRect: rect, cornerRadius: 1.5)

                        if isCurrent {
                            ctx.fill(path, with: .color(Color.accentSecondary))
                        } else if isLived {
                            ctx.fill(path, with: .color(Color.accentPrimary.opacity(0.75)))
                        } else {
                            ctx.fill(path, with: .color(Color.secondary.opacity(0.12)))
                        }
                    }
                }
            }
            .frame(width: totalW, height: totalH)
        }
    }

    // MARK: - Inspiration section
    private var inspirationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.string("lifespan.inspire.title"))
                .font(.appTitle)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16) {
                inspirationCard(
                    icon: "sun.max.fill", color: .pastelPeach,
                    value: fmt(daysRemaining),
                    label: localization.string("lifespan.inspire.days"))
                inspirationCard(
                    icon: "moon.stars.fill", color: .pastelBlue,
                    value: fmt(daysRemaining * 24),
                    label: localization.string("lifespan.inspire.hours"))
                inspirationCard(
                    icon: "leaf.fill", color: .pastelGreen,
                    value: fmt(weeksRemaining / 13),
                    label: localization.string("lifespan.inspire.seasons"))
            }

            // Motivational quote
            HStack(spacing: 16) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.accentPrimary, .accentSecondary],
                        startPoint: .top, endPoint: .bottom))
                    .frame(width: 4)
                    .clipShape(Capsule())
                Text(localization.string("lifespan.quote"))
                    .font(.appBody)
                    .italic()
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous))
            .shadow(color: AppStyle.shadowColor, radius: AppStyle.shadowRadius, x: 0, y: AppStyle.shadowY)
        }
    }

    private func inspirationCard(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label)
                .font(.appCaption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous))
        .shadow(color: AppStyle.shadowColor, radius: AppStyle.shadowRadius, x: 0, y: AppStyle.shadowY)
    }
}
