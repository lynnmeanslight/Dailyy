import SwiftUI

// MARK: - Sidebar Navigation
struct SidebarView: View {
    @Binding var selected: AppSection
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            // App brand
            VStack(spacing: 4) {
                Image(systemName: "camera.macro")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.accentPrimary, .accentSecondary],
                                       startPoint: .top, endPoint: .bottom))
                Text("Dailyy")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("တစ်နေ့တာ")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 28)

            // Nav items
            VStack(spacing: 6) {
                ForEach(AppSection.allCases) { section in
                    SidebarItem(section: section, isSelected: selected == section) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selected = section
                        }
                    }
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            // Bottom decorative area
            VStack(spacing: 4) {
                Text(localization.string("app.tagline"))
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Text(Date().dayMonthYear)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 220)
        .background(Color.sidebarBg)
    }
}

// MARK: - Sidebar Item
struct SidebarItem: View {
    let section: AppSection
    let isSelected: Bool
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : section.color)
                    .frame(width: 22)

                Text(section.localizedName)
                    .font(.appBody)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : .primary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected
                          ? AnyShapeStyle(LinearGradient(colors: [.accentPrimary, .accentSecondary],
                                                         startPoint: .leading, endPoint: .trailing))
                          : AnyShapeStyle(hovered ? section.color.opacity(0.15) : Color.clear))
            )
            .scaleEffect(hovered && !isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onHover { hovered = $0 }
    }
}

#Preview {
    SidebarView(selected: .constant(.dashboard))
        .frame(width: 220, height: 600)
}
