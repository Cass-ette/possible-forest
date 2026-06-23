import SwiftUI

struct HomeView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showStats: Bool = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 18) {
                        petZone
                        personalityPanel
                        if let task = game.currentTask {
                            TaskCardView(task: task)
                        } else {
                            endOfDayView
                        }
                    }
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 20)

            if game.showCelebration {
                CelebrationOverlay()
                    .allowsHitTesting(false)
                    .onAppear {
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(1.6))
                            withAnimation { game.showCelebration = false }
                        }
                    }
            }

            if game.showStageUp, let stage = game.pendingStageUp {
                StageUpOverlay(stage: stage) {
                    withAnimation { game.showStageUp = false }
                }
            }
        }
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(game.pet.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(game.pet.stage.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .glassCapsule()
                }
                Text("性格 · \(game.pet.personality.dominant())")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("XP")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Theme.textSecondary)
                Text("\(game.pet.xp)")
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .glassCard(cornerRadius: 16)
        }
        .padding(.vertical, 10)
    }

    private var petZone: some View {
        VStack(spacing: 14) {
            PetDialogBubble(text: game.currentDialog)
                .padding(.top, 4)
            PetCharacterView(stage: game.pet.stage, mood: game.pet.mood)
                .frame(height: 220)
                .padding(.vertical, 4)
        }
    }

    private var personalityPanel: some View {
        PersonalityPanel(personality: game.pet.personality)
            .padding(.horizontal)
    }

    private var endOfDayView: some View {
        GlassCard {
            VStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 46))
                    .foregroundStyle(.orange)
                Text("今天的旅程告一段落")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("明天会有新的可能性")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Text("完成 \(game.completedTaskIDs.count) 个任务 · \(game.pet.xp) XP")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Theme.textSecondary)

                Button {
                    game.reset()
                } label: {
                    Label("重新开始今天的旅程", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.petPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassCapsule()
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }
}

struct CelebrationOverlay: View {
    @State private var particles: [Confetti] = (0..<24).map { _ in Confetti() }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size)
                    .position(p.position)
                    .opacity(p.opacity)
            }

            Image(systemName: "sparkles")
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(.yellow)
                .shadow(color: .orange.opacity(0.6), radius: 20)
                .transition(.scale.combined(with: .opacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear { animateConfetti() }
    }

    private func animateConfetti() {
        for i in particles.indices {
            let delay = Double.random(in: 0...0.3)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 1.3)) {
                    particles[i].position.y += 280
                    particles[i].opacity = 0
                }
            }
        }
    }
}

struct StageUpOverlay: View {
    let stage: PetStage
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 16) {
                Text("✨ 长大啦 ✨").font(.title2.weight(.bold)).foregroundStyle(.white)

                PetCharacterView(stage: stage, mood: .celebrating)
                    .frame(height: 200)

                Text("变成了「\(stage.rawValue)」形态")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Tap to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(32)
            .glassCard(cornerRadius: 32)
            .padding(.horizontal, 48)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct Confetti: Identifiable {
    let id = UUID()
    var position: CGPoint = CGPoint(
        x: CGFloat.random(in: 40...350),
        y: CGFloat.random(in: 150...300)
    )
    let color: Color = [.yellow, .pink, .orange, .green, .blue, .purple].randomElement() ?? .yellow
    let size: CGFloat = CGFloat.random(in: 8...16)
    var opacity: Double = 1.0
}

struct PersonalityPanel: View {
    let personality: PetPersonality

    var body: some View {
        GlassCard(cornerRadius: 22, padding: 16) {
            VStack(spacing: 8) {
                traitBar("勤奋", value: personality.diligence, color: Color(hex: 0x6E84FF))
                traitBar("灵活", value: personality.flexibility, color: Color(hex: 0xB57BFF))
                traitBar("耐心", value: personality.patience, color: Color(hex: 0xFF9F6B))
                traitBar("好奇", value: personality.curiosity, color: Color(hex: 0x5BCB8B))
            }
        }
    }

    private func traitBar(_ label: String, value: Float, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 32, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.textPrimary.opacity(0.1))
                        .frame(height: 6)
                    Capsule()
                        .fill(color)
                        .frame(width: max(8, geo.size.width * CGFloat(value)), height: 6)
                }
            }
            .frame(height: 6)
            Text("\(Int(value * 100))")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 28, alignment: .trailing)
        }
    }
}
