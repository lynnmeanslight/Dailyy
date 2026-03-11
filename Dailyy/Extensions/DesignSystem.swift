import SwiftUI

// MARK: - Colour Palette  (Duolingo-style)

// Helper to create colours that adapt to light/dark mode
private func adaptiveColor(light: NSColor, dark: NSColor) -> Color {
    Color(NSColor(name: nil, dynamicProvider: { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
    }))
}

extension Color {
    // Pastel card backgrounds — adaptive light / dark variants
    static let pastelPink   = adaptiveColor(
        light: NSColor(red: 1.000, green: 0.780, blue: 0.890, alpha: 1),
        dark:  NSColor(red: 0.48,  green: 0.16,  blue: 0.30,  alpha: 1))
    static let pastelPurple = adaptiveColor(
        light: NSColor(red: 0.902, green: 0.839, blue: 1.000, alpha: 1),
        dark:  NSColor(red: 0.31,  green: 0.21,  blue: 0.56,  alpha: 1))
    static let pastelBlue   = adaptiveColor(
        light: NSColor(red: 0.722, green: 0.906, blue: 1.000, alpha: 1),
        dark:  NSColor(red: 0.11,  green: 0.31,  blue: 0.56,  alpha: 1))
    static let pastelGreen  = adaptiveColor(
        light: NSColor(red: 0.812, green: 0.969, blue: 0.694, alpha: 1),
        dark:  NSColor(red: 0.16,  green: 0.44,  blue: 0.11,  alpha: 1))
    static let pastelPeach  = adaptiveColor(
        light: NSColor(red: 1.000, green: 0.910, blue: 0.639, alpha: 1),
        dark:  NSColor(red: 0.52,  green: 0.33,  blue: 0.08,  alpha: 1))
    static let pastelYellow = adaptiveColor(
        light: NSColor(red: 1.000, green: 0.973, blue: 0.745, alpha: 1),
        dark:  NSColor(red: 0.46,  green: 0.41,  blue: 0.10,  alpha: 1))
    static let pastelMint   = pastelGreen  // alias

    // Semantic
    static let accentPrimary   = Color(red: 0.345, green: 0.800, blue: 0.008)  // #58CC02 Duolingo Green
    static let accentSecondary = Color(red: 0.110, green: 0.690, blue: 0.965)  // #1CB0F6 Sky Blue
    static let cardBackground = Color(NSColor.controlBackgroundColor)
    static let sidebarBg     = Color(NSColor.windowBackgroundColor)

    // Category colours
    static let categoryFood      = Color(red: 1.000, green: 0.588, blue: 0.000)  // #FF9600 orange
    static let categoryTransport = Color(red: 0.110, green: 0.690, blue: 0.965)  // #1CB0F6 sky blue
    static let categoryShopping  = Color(red: 0.808, green: 0.510, blue: 1.000)  // #CE82FF soft purple
    static let categoryBills     = Color(red: 1.000, green: 0.851, blue: 0.000)  // #FFD900 yellow
    static let categoryEntertain = Color(red: 1.000, green: 0.420, blue: 0.616)  // #FF6B9D cute pink
    static let categoryOther     = Color(red: 0.898, green: 0.898, blue: 0.898)  // #E5E5E5 light gray

    static func forCategory(_ category: String) -> Color {
        switch category {
        case "Food":          return .categoryFood
        case "Transport":     return .categoryTransport
        case "Shopping":      return .categoryShopping
        case "Bills":         return .categoryBills
        case "Entertainment": return .categoryEntertain
        default:              return .categoryOther
        }
    }

    // 50/30/20 rule colours
    static let needsColor   = Color(red: 0.345, green: 0.800, blue: 0.008)  // #58CC02 Duolingo Green — needs
    static let wantsColor   = Color(red: 1.000, green: 0.588, blue: 0.000)  // #FF9600 Orange — wants
    static let savingsColor = Color(red: 1.000, green: 0.851, blue: 0.000)  // #FFD900 Yellow — savings
}

// MARK: - Typography
extension Font {
    static let appTitle   = Font.system(size: 24, weight: .bold,   design: .rounded)
    static let appHeading = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let appBody    = Font.system(size: 14, weight: .regular, design: .rounded)
    static let appCaption = Font.system(size: 12, weight: .regular, design: .rounded)
    static let appMono    = Font.system(size: 13, weight: .medium,  design: .monospaced)
}

// MARK: - Shadows & Radius
struct AppStyle {
    static let cornerRadius: CGFloat = 16
    static let cardRadius: CGFloat   = 20
    static let shadowRadius: CGFloat = 8
    static let shadowColor = adaptiveColor(
        light: NSColor.black.withAlphaComponent(0.09),
        dark:  NSColor.black.withAlphaComponent(0.35))
    static let shadowY: CGFloat      = 4
}

// MARK: - Card modifier
struct CardModifier: ViewModifier {
    var padding: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous))
            .shadow(color: AppStyle.shadowColor, radius: AppStyle.shadowRadius, x: 0, y: AppStyle.shadowY)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 20) -> some View {
        self.modifier(CardModifier(padding: padding))
    }
}

// MARK: - Hover glow modifier
struct HoverGlowModifier: ViewModifier {
    @State private var hovered = false
    let color: Color

    func body(content: Content) -> some View {
        content
            .scaleEffect(hovered ? 1.04 : 1.0)
            .shadow(color: color.opacity(hovered ? 0.45 : 0), radius: 12, x: 0, y: 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hovered)
            .onHover { hovered = $0 }
    }
}

extension View {
    func hoverGlow(color: Color = .accentPrimary) -> some View {
        self.modifier(HoverGlowModifier(color: color))
    }
}
