import SwiftUI

/// Test 分支专用的调试面板
/// 长按右上角 XP 徽章 2 秒唤出
struct DebugMenu: View {
    @Environment(GameViewModel.self) private var game
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if isPresented {
                panel
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity),
                        removal: .scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity)
                    ))
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isPresented.toggle()
                }
            } label: {
                Image(systemName: isPresented ? "xmark.circle.fill" : "ladybug.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.black.opacity(0.55), in: Circle())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 8)
        .padding(.top, 4)
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🛠 DEBUG")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.7))
                .tracking(1.5)

            Section("成长") {
                row("+30 XP") {
                    game.pet.gainXP(30)
                    game.showCelebration = true
                }
                row("直接进化") {
                    if let next = game.pet.stage.next {
                        game.pendingStageUp = next
                        game.showStageUp = true
                    }
                }
                row("跳到成年") {
                    game.pet.stage = .adult
                    game.pet.xp = PetStage.adult.minXP
                }
            }

            Section("性格") {
                row("勤奋 MAX") { game.pet.personality.diligence = 1.0 }
                row("灵活 MAX") { game.pet.personality.flexibility = 1.0 }
                row("耐心 MAX") { game.pet.personality.patience = 1.0 }
                row("好奇 MAX") { game.pet.personality.curiosity = 1.0 }
                row("随机性格") {
                    game.pet.personality.diligence = Float.random(in: 0...1)
                    game.pet.personality.flexibility = Float.random(in: 0...1)
                    game.pet.personality.patience = Float.random(in: 0...1)
                    game.pet.personality.curiosity = Float.random(in: 0...1)
                }
            }

            Section("流程") {
                row("重置 Demo（独立任务）") { game.reset() }
                row("加载剧情 Demo（9 分支）") { game.loadStoryDemo() }
                row("加载独立任务样本") { game.loadSimpleSamples() }
                row("清空所有任务") { game.clearAllTasks() }
                row("回到 Onboarding") {
                    UserDefaults.standard.set(false, forKey: "didOnboard")
                    game.reset()
                }
            }

            Section("跳到任意任务") {
                ForEach(Array(game.allTasks.enumerated()), id: \.element.id) { idx, task in
                    let state = taskStateLabel(task)
                    row("[\(idx)] \(task.title)  \(state)") {
                        game.currentTaskID = task.id
                    }
                }
            }
        }
        .padding(14)
        .frame(width: 280, alignment: .leading)
        .background(.ultraThinMaterial.opacity(0.95), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func Section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.petPrimary)
                .tracking(1)
            VStack(alignment: .leading, spacing: 2) { content() }
        }
    }

    private func row(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(.white.opacity(0.08), in: .rect(cornerRadius: 6))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func taskStateLabel(_ task: TaskNode) -> String {
        if task.isCompleted {
            return "✓"
        }
        if game.unlockedTaskIDs.contains(task.id) {
            return "→"
        }
        return "🔒"
    }
}
