import SwiftUI

/// 新建/编辑任务表单（独立任务，不影响预设拓扑）
struct TaskEditForm: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.dismiss) private var dismiss

    var editing: TaskNode?

    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var category: TaskCategory = .life
    @State private var day: Int = 1

    init(editing: TaskNode? = nil) {
        self.editing = editing
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        titleSection
                        categorySection
                        daySection
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(editing == nil ? "新任务" : "编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .onAppear { loadIfEditing() }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            label("标题")
            TextField("例如：写报告", text: $title)
                .font(.body.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .glassCard(cornerRadius: 14)

            label("副标题（可选）")
            TextField("一句话描述", text: $subtitle)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .glassCard(cornerRadius: 14)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            label("分类")
            HStack(spacing: 8) {
                ForEach(TaskCategory.allCases, id: \.self) { c in
                    Button {
                        category = c
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: c.icon).font(.title3)
                            Text(c.rawValue).font(.caption2.weight(.medium))
                        }
                        .foregroundStyle(category == c ? .white : c.tint)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            category == c
                                ? AnyShapeStyle(c.tint)
                                : AnyShapeStyle(c.tint.opacity(0.15))
                        )
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    private var daySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            label("安排在第几天")
            HStack(spacing: 8) {
                ForEach([1, 2, 3], id: \.self) { d in
                    Button {
                        day = d
                    } label: {
                        Text(["今天", "明天", "后天"][d - 1])
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(day == d ? .white : Theme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                day == d
                                    ? AnyShapeStyle(Theme.petPrimary)
                                    : AnyShapeStyle(Theme.petPrimary.opacity(0.12))
                            )
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            HStack {
                Text("更远")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Stepper("第 \(day) 天", value: $day, in: 1...30)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 14)
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text(editing == nil ? "加入计划" : "保存修改")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.petPrimary, in: .rect(cornerRadius: 18, style: .continuous))
                .shadow(color: Theme.petPrimary.opacity(0.35), radius: 10, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
        .padding(.top, 8)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.textSecondary)
    }

    private func loadIfEditing() {
        guard let e = editing else { return }
        title = e.title
        subtitle = e.subtitle
        category = e.category
        day = e.day
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        let icon = category.icon
        if let e = editing {
            var updated = e
            updated.title = trimmedTitle
            updated.subtitle = subtitle.trimmingCharacters(in: .whitespaces)
            updated.category = category
            updated.icon = icon
            updated.day = day
            game.updateTask(updated)
        } else {
            let task = TaskNode(
                title: trimmedTitle,
                subtitle: subtitle.trimmingCharacters(in: .whitespaces),
                category: category,
                icon: icon,
                day: day,
                outcomes: [:]
            )
            game.addTask(task)
        }
        dismiss()
    }
}
