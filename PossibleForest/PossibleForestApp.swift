import SwiftUI

@main
struct PossibleForestApp: App {
    @State private var game = GameViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(game)
                .animation(.spring(response: 0.45, dampingFraction: 0.75), value: game.pet.xp)
                .animation(.spring(response: 0.45, dampingFraction: 0.75), value: game.pet.stage)
        }
    }
}

struct RootView: View {
    @Environment(GameViewModel.self) private var game
    @AppStorage("didOnboard") private var didOnboard = false

    var body: some View {
        if didOnboard {
            HomeView()
        } else {
            OnboardingView()
        }
    }
}
