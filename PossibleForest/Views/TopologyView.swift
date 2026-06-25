import SwiftUI

/// 整个剧情的拓扑可视化
/// Day 1 (1 节点) → Day 2 (3 节点) → Day 3 (9 节点)
/// 边的颜色按结局类型: 完美=薄荷 / 部分=琥珀 / 改天=紫罗兰
struct TopologyView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn: Bool = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                legend
                graphScroll
            }
        }
        .presentationDetents([.large])
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.05)) {
                animateIn = true
            }
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("可能性的地图").font(.title2.weight(.bold)).foregroundStyle(Theme.textPrimary)
                Text("每条路都通向新的森林").font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(color: .mint, label: "完成", icon: "checkmark.circle.fill")
            legendItem(color: .orange, label: "部分", icon: "circle.lefthalf.filled")
            legendItem(color: .purple, label: "改天", icon: "moon.zzz.fill")
            Spacer()
            legendItem(color: .green, label: "已过", icon: "checkmark.seal.fill")
            legendItem(color: Theme.petPrimary, label: "当前", icon: "dot.radiowaves.left.and.right")
            legendItem(color: .gray, label: "未解锁", icon: "lock.fill")
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Theme.textSecondary)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private func legendItem(color: Color, label: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(color)
            Text(label)
        }
    }

    private var graphScroll: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                edgesLayer
                nodesLayer
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .padding(20)
        }
        .scrollIndicators(.hidden)
    }

    private var canvasSize: CGSize {
        let maxDay = max(1, game.allTasks.map(\.day).max() ?? 1)
        let maxCount = (1...maxDay).map { day in
            game.allTasks.filter { $0.day == day }.count
        }.max() ?? 1
        let width = max(800, CGFloat(maxCount - 1) * 130 + 240)
        let height = max(500, CGFloat(maxDay - 1) * 220 + 200)
        return CGSize(width: width, height: height)
    }

    // MARK: - Layers

    private var edgesLayer: some View {
        Canvas { ctx, _ in
            for edge in allEdges {
                var path = Path()
                let from = edge.from
                let to = edge.to
                let mid = CGPoint(x: from.x, y: (from.y + to.y) / 2)
                path.move(to: from)
                path.addQuadCurve(to: to, control: mid)
                ctx.stroke(path, with: .color(edge.color.opacity(edge.opacity)),
                           style: StrokeStyle(lineWidth: 2.5,
                                              dash: edge.dashed ? [4, 4] : []))
            }
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(0.15), value: animateIn)
    }

    private var nodesLayer: some View {
        ForEach(game.allTasks) { task in
            NodeBubble(task: task, isCurrent: task.id == game.currentTaskID)
                .position(nodePosition(for: task))
                .scaleEffect(animateIn ? 1 : 0.4)
                .opacity(animateIn ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(delay(for: task)),
                           value: animateIn)
        }
    }

    // MARK: - Layout

    private func nodePosition(for task: TaskNode) -> CGPoint {
        let dayTasks = game.allTasks
            .filter { $0.day == task.day }
            .sorted { $0.order < $1.order }
        let count = dayTasks.count
        let idx = dayTasks.firstIndex(where: { $0.id == task.id }) ?? 0

        let totalWidth = CGFloat(max(1, count - 1)) * 130
        let startX = (canvasSize.width - totalWidth) / 2
        let x = startX + CGFloat(idx) * 130
        let y = 90 + CGFloat(max(0, task.day - 1)) * 220
        return CGPoint(x: x, y: y)
    }

    private func delay(for task: TaskNode) -> Double {
        Double(task.day - 1) * 0.2 + Double(task.day) * 0.05
    }

    private var allEdges: [Edge] {
        var result: [Edge] = []
        let tasksWithBranches = game.allTasks.filter { task in
            task.outcomes.values.contains { !$0.unlockTaskIDs.isEmpty }
        }
        let branchedIDs = Set(tasksWithBranches.map(\.id))

        // 1. 预设拓扑连接（9 分支剧情）
        for task in game.allTasks where branchedIDs.contains(task.id) {
            let fromPos = nodePosition(for: task)
            for outcome in task.outcomes.values {
                for unlockID in outcome.unlockTaskIDs {
                    if let toTask = game.allTasks.first(where: { $0.id == unlockID }) {
                        let toPos = nodePosition(for: toTask)
                        let unlocked = game.unlockedTaskIDs.contains(toTask.id)
                        result.append(Edge(
                            from: fromPos,
                            to: toPos,
                            color: colorFor(outcome.type),
                            opacity: unlocked ? 0.85 : 0.35,
                            dashed: !unlocked
                        ))
                    }
                }
            }
        }

        // 2. 同一天的独立任务按顺序串联（计划路径）
        let maxDay = max(1, game.allTasks.map(\.day).max() ?? 1)
        for day in 1...maxDay {
            let dayTasks = game.allTasks
                .filter { $0.day == day && !branchedIDs.contains($0.id) }
                .sorted { $0.order < $1.order }
            for i in 0..<(dayTasks.count - 1) {
                let prev = dayTasks[i]
                let next = dayTasks[i + 1]
                let fromPos = nodePosition(for: prev)
                let toPos = nodePosition(for: next)
                let (color, opacity, dashed) = sequentialEdgeStyle(for: prev)
                result.append(Edge(
                    from: fromPos,
                    to: toPos,
                    color: color,
                    opacity: opacity,
                    dashed: dashed
                ))
            }
        }

        return result
    }

    /// 根据 prev 任务的完成状态，决定顺序边的样式
    private func sequentialEdgeStyle(for prev: TaskNode) -> (color: Color, opacity: Double, dashed: Bool) {
        if !prev.isCompleted {
            return (.gray, 0.4, true) // 计划中
        }
        switch prev.chosenOutcome {
        case .perfect: return (.mint, 0.85, false)
        case .partial: return (.orange, 0.85, false)
        case .abandon: return (.purple, 0.85, false)
        case .none: return (.gray, 0.4, true)
        }
    }

    private var _legacyEdgesStub: [Edge] {
        []
    }

    private func colorFor(_ type: OutcomeType) -> Color {
        switch type {
        case .perfect: return .mint
        case .partial: return .orange
        case .abandon: return .purple
        }
    }
}

// MARK: - Edge

private struct Edge: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
    let color: Color
    let opacity: Double
    let dashed: Bool
}

// MARK: - Node Bubble

struct NodeBubble: View {
    let task: TaskNode
    let isCurrent: Bool
    @Environment(GameViewModel.self) private var game

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = sin(timeline.date.timeIntervalSinceReferenceDate * 2.5)
            ZStack {
                Circle()
                    .fill(stateColor.opacity(0.25))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isCurrent ? 1 + 0.08 * phase : 1)

                Circle()
                    .fill(.white.opacity(0.92))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle().stroke(stateColor, lineWidth: isCurrent ? 3 : 2)
                    )

                Image(systemName: task.icon ?? task.category.icon)
                    .font(.title2)
                    .foregroundStyle(stateColor)

                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(stateColor, in: Circle())
                        .offset(x: 22, y: -22)
                }
            }
            .overlay(alignment: .bottom) {
                Text(task.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: .capsule)
                    .offset(y: 22)
            }
        }
    }

    private var stateColor: Color {
        if task.isCompleted { return .green }
        if isCurrent { return Theme.petPrimary }
        if game.unlockedTaskIDs.contains(task.id) { return task.category.tint }
        return .gray
    }
}
