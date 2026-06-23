import SwiftUI

struct PetDialogBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.body.weight(.medium))
            .foregroundStyle(Theme.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .glassCard(cornerRadius: 22)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 320)
            .id(text)
    }
}
