import SwiftUI
import Observation

@Observable
final class GameViewModel {
    var pet: Pet
    var allTasks: [TaskNode]
    var unlockedTaskIDs: Set<UUID>
    var completedTaskIDs: Set<UUID>
    var currentTaskID: UUID?
    var lastDialog: String?
    var lastOutcomeType: OutcomeType?
    var showCelebration: Bool = false
    var showStageUp: Bool = false
    var pendingStageUp: PetStage?

    init() {
        let tasks = TaskLibrary.simpleSamples()
        self.pet = Pet(name: "芽芽")
        self.allTasks = tasks
        // 默认所有任务都解锁（独立任务可任意选择）
        self.unlockedTaskIDs = Set(tasks.map(\.id))
        self.completedTaskIDs = Set()
        self.currentTaskID = tasks.first?.id
    }

    var currentTask: TaskNode? {
        guard let id = currentTaskID else { return nil }
        return allTasks.first { $0.id == id }
    }

    var currentDay: Int {
        currentTask?.day ?? 0
    }

    var smartDialog: String {
        if let last = lastDialog, !last.isEmpty {
            return last
        }
        return suggestFromPersonality()
    }

    var currentDialog: String {
        smartDialog
    }

    private func suggestFromPersonality() -> String {
        guard currentTask != nil else {
            return "今天的旅程告一段落，明天再来吧"
        }
        let p = pet.personality
        if p.diligence > 0.7 {
            return "状态超棒！挑战一下重点任务？"
        }
        if p.flexibility > 0.7 {
            return "看你挺随性的，挑个轻量的热身？"
        }
        if p.curiosity > 0.7 {
            return "试试新支线？走走没走过的路。"
        }
        if p.patience < 0.3 {
            return "耐心见底啦，做点简单的放松下？"
        }
        return "今天先做这个吧～"
    }

    var isFinished: Bool {
        guard let task = currentTask else { return true }
        return task.outcomes.isEmpty
    }

    func choose(_ type: OutcomeType) {
        guard let task = currentTask, !task.isCompleted else { return }
        // 独立任务（无预设结局）用默认反馈
        let outcome = task.outcome(for: type) ?? TaskOutcome.defaultOutcome(type, task: task)

        // Mark task completed
        if let idx = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[idx].isCompleted = true
            allTasks[idx].chosenOutcome = type
        }
        completedTaskIDs.insert(task.id)
        lastDialog = outcome.petDialog
        lastOutcomeType = type

        // Unlock next tasks
        for id in outcome.unlockTaskIDs {
            unlockedTaskIDs.insert(id)
        }

        // Pet evolution
        let previousStage = pet.stage
        pet.gainXP(outcome.xpGain)
        pet.apply(outcome.personalityDelta)
        pet.mood = moodFor(type)

        if pet.stage != previousStage {
            pendingStageUp = pet.stage
            showStageUp = true
        } else if type == .perfect {
            showCelebration = true
        }

        // Advance to next task
        advance()
    }

    // MARK: - CRUD

    func addTask(_ task: TaskNode) {
        var newTask = task
        if newTask.day < 1 { newTask.day = 1 }
        allTasks.append(newTask)
        unlockedTaskIDs.insert(newTask.id)
        if currentTaskID == nil {
            currentTaskID = newTask.id
        }
    }

    func updateTask(_ task: TaskNode) {
        guard let idx = allTasks.firstIndex(where: { $0.id == task.id }) else { return }
        allTasks[idx] = task
    }

    func deleteTask(id: UUID) {
        allTasks.removeAll { $0.id == id }
        completedTaskIDs.remove(id)
        unlockedTaskIDs.remove(id)
        // 清理其他任务对它的引用
        for i in allTasks.indices {
            for outcome in allTasks[i].outcomes.values {
                let _ = outcome // 不变，但 unlockTaskIDs 可能指向已删的任务
            }
        }
        if currentTaskID == id {
            currentTaskID = allTasks.first { !completedTaskIDs.contains($0.id) }?.id
        }
    }

    // MARK: - 切换数据集

    func loadStoryDemo() {
        let tasks = TaskLibrary.demoTree()
        allTasks = tasks
        unlockedTaskIDs = Set([tasks.first?.id].compactMap { $0 })
        completedTaskIDs = Set()
        lastDialog = nil
        lastOutcomeType = nil
        currentTaskID = tasks.first?.id
    }

    func loadSimpleSamples() {
        let tasks = TaskLibrary.simpleSamples()
        allTasks = tasks
        unlockedTaskIDs = Set(tasks.map(\.id))
        completedTaskIDs = Set()
        lastDialog = nil
        lastOutcomeType = nil
        currentTaskID = tasks.first?.id
    }

    func clearAllTasks() {
        allTasks = []
        unlockedTaskIDs = Set()
        completedTaskIDs = Set()
        currentTaskID = nil
        lastDialog = nil
    }

    func namePet(_ name: String) {
        pet.name = name
    }

    func reset() {
        let tasks = TaskLibrary.simpleSamples()
        pet = Pet(name: pet.name.isEmpty ? "芽芽" : pet.name)
        allTasks = tasks
        unlockedTaskIDs = Set(tasks.map(\.id))
        completedTaskIDs = Set()
        lastDialog = nil
        lastOutcomeType = nil
        currentTaskID = tasks.first?.id
    }

    /// 跳到指定任务（用于 PlanView 点击切换）
    func jumpToTask(id: UUID) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentTaskID = id
        }
    }

    private func advance() {
        let next = allTasks.first { unlockedTaskIDs.contains($0.id) && !completedTaskIDs.contains($0.id) }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            currentTaskID = next?.id
        }
    }

    private func moodFor(_ type: OutcomeType) -> PetMood {
        switch type {
        case .perfect: return .celebrating
        case .partial: return .encouraging
        case .abandon: return .thoughtful
        }
    }
}
