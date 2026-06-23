import SwiftUI

struct OnboardingView: View {
    @Environment(GameViewModel.self) private var game
    @AppStorage("didOnboard") private var didOnboard = false
    @State private var name: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 24)

                VStack(spacing: 4) {
                    Text("可能森林")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Possible Forest")
                        .font(.title3.weight(.light))
                        .tracking(2)
                        .foregroundStyle(Theme.textSecondary)
                }

                PetCharacterView(stage: .seed, mood: .happy)
                    .frame(height: 200)

                Text("这里没有失败，只有转向。\n你的小生灵会陪你走过每一种可能。")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 16) {
                    Text("给 TA 起个名字吧")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    HStack {
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(Theme.petPrimary)
                        TextField("芽芽 / Mochi / 豆豆", text: $name)
                            .focused($focused)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .submitLabel(.done)
                            .onSubmit { completeOnboarding() }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .glassCard(cornerRadius: 18)
                    .padding(.horizontal, 32)

                    Button {
                        completeOnboarding()
                    } label: {
                        Text("进入森林")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.petPrimary, in: .rect(cornerRadius: 20, style: .continuous))
                            .shadow(color: Theme.petPrimary.opacity(0.35), radius: 12, y: 6)
                            .padding(.horizontal, 32)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear { focused = true }
    }

    private func completeOnboarding() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        game.namePet(trimmed.isEmpty ? "芽芽" : trimmed)
        withAnimation(.easeInOut(duration: 0.45)) {
            didOnboard = true
        }
    }
}
