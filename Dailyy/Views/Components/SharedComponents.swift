import SwiftUI

// MARK: - Animated Progress Bar
struct AnimatedProgressBar: View {
    let value: Double       // 0.0 – 1.0
    let color: Color
    let height: CGFloat

    @State private var animatedValue: Double = 0

    init(value: Double, color: Color, height: CGFloat = 10) {
        self.value = value
        self.color = color
        self.height = height
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color.opacity(0.18))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * min(animatedValue, 1.0), height: height)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { _, new in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedValue = new
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.appTitle)
                .foregroundStyle(.primary)
            Text(title)
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
        .hoverGlow(color: color)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { appeared = true }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.appHeading)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Floating Add Button
struct FloatingAddButton: View {
    let action: () -> Void
    @State private var hovered = false
    @State private var pressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { pressed = false }
                action()
            }
        }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [.accentPrimary, .accentSecondary],
                        startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: .accentPrimary.opacity(0.45), radius: hovered ? 16 : 8, x: 0, y: 4)
                .scaleEffect(pressed ? 0.88 : (hovered ? 1.10 : 1.0))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: hovered)
        .onHover { hovered = $0 }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.appCaption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.appHeading)
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.appBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Confetti particle for birthday
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Text(p.symbol)
                    .font(.system(size: p.size))
                    .position(p.position)
                    .rotationEffect(.degrees(p.rotation))
                    .opacity(p.opacity)
            }
        }
        .onAppear { spawnParticles() }
    }

    private func spawnParticles() {
        particles = (0..<30).map { _ in ConfettiParticle() }
        withAnimation(.easeOut(duration: 2.0)) {
            for i in particles.indices {
                particles[i].position = CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 200...400))
                particles[i].opacity = 0
                particles[i].rotation = Double.random(in: 0...720)
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var symbol: String = ["🎉","🎊","⭐️","✨","🌟","💫","🎈"][Int.random(in: 0...6)]
    var position: CGPoint = CGPoint(x: CGFloat.random(in: 50...350), y: CGFloat.random(in: 50...150))
    var size: CGFloat = CGFloat.random(in: 12...28)
    var rotation: Double = 0
    var opacity: Double = 1.0
}
