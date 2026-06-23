import SwiftUI

/// 今日计划：列出所有任务 + 添加 + 编辑 + 删除
struct PlanView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.dismiss) private var dismiss
    @State private var showAddForm: Bool = false
    @State private var editingTask: TaskNode?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard
                        ForEach(1...maxDays, id: \.self) { d in
                            daySection(d)
                        }
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                addButton
            }
            .navigationTitle("我的计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(Theme.petPrimary)
                        .font(.headline)
                }
            }
            .sheet(isPresented: $showAddForm) {
                TaskEditForm()
            }
            .sheet(item: $editingTask) { task in
                TaskEditForm(editing: task)
            }
        }
    }

    private var maxDays: Int {
        max(1, game.allTasks.map(\.day).max() ?? 1)
    }

    private var summaryCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总共 \(game.allTasks.count) 个任务").font(.caption.weight(.semibold)).foregroundStyle(Theme.textSecondary)
                    Text("\(game.completedTaskIDs.count) 已完成").font(.title3.weight(.bold)).foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                Text(game.pet.name).font(.title2.weight(.bold)).foregroundStyle(Theme.petPrimary)
            }
        }
    }

    @ViewBuilder
    private func daySection(_ day: Int) -> some View {
        let tasks = game.allTasks.filter { $0.day == day }
        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("第 \(day) 天").font(.subheadline.weight(.bold)).foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(tasks.filter { $0.isCompleted }.count) / \(tasks.count)")
                        .font(.caption.weight(.semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Theme.petPrimary.opacity(0.8), in: .capsule)
                }.padding(.horizontal, 4)

                ForEach(tasks) { task in
                    PlanTaskRow(
                        task: task,
                        isCurrent: task.id == game.currentTaskID,
                        onEdit: { editingTask = task },
                        onDelete: { game.deleteTask(id: task.id) },
                        onTap: { game.jumpToTask(id: task.id); dismiss() }
                    )
                }
            }
        }
    }

    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showAddForm = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Theme.petPrimary, in: Circle())
                        .shadow(color: Theme.petPrimary.opacity(0.4), radius: 10, y: 5)
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

struct PlanTaskRow: View {
    let task: TaskNode
    let isCurrent: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        Menu {
            Button { onTap() } label: { Label("设为当前", systemImage: "target") }
            Button { onEdit() } label: { Label("编辑", systemImage: "pencil") }
            Divider()
            Button(role: .destructive) { onDelete() } label: { Label("删除", systemImage: "trash") }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(task.category.tint.opacity(0.2)).frame(width: 40, height: 40)
                    Image(systemName: task.icon ?? task.category.icon).foregroundStyle(task.category.tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(task.title).font(.body.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .strikethrough(task.isCompleted, color: Theme.textSecondary)
                        if isCurrent {
                            Text("当前").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.petPrimary, in: .capsule)
                        }
                        if task.isCompleted {
                            Image(systemName: statusIcon)
                                .foregroundStyle(statusColor)
                                .font(.caption)
                        }
                    }
                    if !task.subtitle.isEmpty {
                        Text(task.subtitle).font(.caption).foregroundStyle(Theme.textSecondary).lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "ellipsis").font(.caption).foregroundStyle(Theme.textSecondary)
            }
            .padding(14)
            .glassCard(cornerRadius: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isCurrent ? Theme.petPrimary.opacity(0.6) : .clear, lineWidth: 2)
            )
        }
    }

    private var statusIcon: String {
        switch task.chosenOutcome {
        case .perfect: return "checkmark.circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .abandon: return "moon.zzz.fill"
        case .none: return "checkmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch task.chosenOutcome {
        case .perfect: return .green
        case .partial: return .orange
        case .abandon: return .purple
        case .none: return .green
        }
    }
}
