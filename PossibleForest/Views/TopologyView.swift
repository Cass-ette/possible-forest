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
            .frame(width: 1000, height: 720)
            .padding(20)
        }
        .scrollIndicators(.hidden)
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
        let dayTasks = game.allTasks.filter { $0.day == task.day }
        let idx = dayTasks.firstIndex(where: { $0.id == task.id }) ?? 0
        switch task.day {
        case 1: return CGPoint(x: 500, y: 80)
        case 2: return CGPoint(x: 200 + CGFloat(idx) * 300, y: 300)
        case 3: return CGPoint(x: 60 + CGFloat(idx) * 105, y: 560)
        default: return .zero
        }
    }

    private func delay(for task: TaskNode) -> Double {
        Double(task.day - 1) * 0.2 + Double(task.day) * 0.05
    }

    private var allEdges: [Edge] {
        var result: [Edge] = []
        for task in game.allTasks {
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
                            opacity: unlocked ? 0.85 : 0.3,
                            dashed: !unlocked
                        ))
                    }
                }
            }
        }
        return result
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
