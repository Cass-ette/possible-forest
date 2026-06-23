import SwiftUI

struct TaskCardView: View {
    let task: TaskNode
    @Environment(GameViewModel.self) private var game
    @State private var showEdit: Bool = false
    @State private var showActions: Bool = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                header
                Divider().opacity(0.4)
                actions
            }
        }
        .padding(.horizontal)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.92).combined(with: .opacity),
            removal: .scale(scale: 0.96).combined(with: .opacity)
        ))
        .id(task.id)
        .contextMenu {
            Button { showEdit = true } label: { Label("编辑任务", systemImage: "pencil") }
            Button(role: .destructive) { game.deleteTask(id: task.id) } label: {
                Label("删除任务", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEdit) {
            TaskEditForm(editing: task)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(task.category.tint.opacity(0.22))
                    .frame(width: 52, height: 52)
                Image(systemName: task.icon ?? task.category.icon)
                    .font(.title2)
                    .foregroundStyle(task.category.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.category.rawValue.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(task.category.tint)
                Text(task.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(task.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            PrimaryButton(
                title: "完成",
                icon: "checkmark.circle.fill",
                tint: task.category.tint,
                isPrimary: true,
                action: { game.choose(.perfect) }
            )
            HStack(spacing: 10) {
                PrimaryButton(
                    title: "部分",
                    icon: "circle.lefthalf.filled",
                    tint: .orange,
                    action: { game.choose(.partial) }
                )
                PrimaryButton(
                    title: "改天",
                    icon: "moon.zzz.fill",
                    tint: .indigo,
                    action: { game.choose(.abandon) }
                )
            }
        }
    }
}
