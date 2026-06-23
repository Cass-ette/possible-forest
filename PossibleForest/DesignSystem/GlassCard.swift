import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 28
    var padding: CGFloat = 24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity)
            .glassCard(cornerRadius: cornerRadius)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    let icon: String
    let tint: Color
    var isPrimary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPrimary ? 18 : 14)
            .background(
                Group {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: isPrimary ? 22 : 18, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular.tint(tint.opacity(isPrimary ? 0.28 : 0.14)),
                                         in: .rect(cornerRadius: isPrimary ? 22 : 18))
                    } else {
                        RoundedRectangle(cornerRadius: isPrimary ? 22 : 18, style: .continuous)
                            .fill(tint.opacity(isPrimary ? 0.22 : 0.12))
                    }
                }
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}
