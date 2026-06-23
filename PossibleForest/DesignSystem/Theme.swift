import SwiftUI

enum Theme {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: 0xFFE8B0),
            Color(hex: 0xFFD3B6),
            Color(hex: 0xC4E9C9),
            Color(hex: 0xC6DCEC)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let petPrimary = Color(hex: 0xFF9E6B)
    static let petSecondary = Color(hex: 0xFFD3A8)
    static let petAccent = Color(hex: 0x5BA86E)
    static let petLeaf = Color(hex: 0x7BC97F)

    static let textPrimary = Color(hex: 0x3A2B22)
    static let textSecondary = Color(hex: 0x6B5B50)

    static func rounded(_ radius: CGFloat = 24) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension View {
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 28) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func glassCapsule() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .capsule)
        } else {
            self.background(.ultraThinMaterial, in: .capsule)
        }
    }
}
