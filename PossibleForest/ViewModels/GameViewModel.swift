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
        let tasks = TaskLibrary.demoTree()
        self.pet = Pet(name: "芽芽")
        self.allTasks = tasks
        self.unlockedTaskIDs = Set()
        self.completedTaskIDs = Set()
        if let first = tasks.first {
            self.unlockedTaskIDs.insert(first.id)
            self.currentTaskID = first.id
        } else {
            self.currentTaskID = nil
        }
    }

    var currentTask: TaskNode? {
        guard let id = currentTaskID else { return nil }
        return allTasks.first { $0.id == id }
    }

    var currentDialog: String {
        if let last = lastDialog { return last }
        if currentTask != nil {
            return "今天先做这个吧～"
        }
        return "今天的旅程告一段落，明天再来吧"
    }

    var isFinished: Bool {
        guard let task = currentTask else { return true }
        return task.outcomes.isEmpty
    }

    func choose(_ type: OutcomeType) {
        guard let task = currentTask, !task.isCompleted else { return }
        guard let outcome = task.outcome(for: type) else { return }

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

    func namePet(_ name: String) {
        pet.name = name
    }

    func reset() {
        let tasks = TaskLibrary.demoTree()
        pet = Pet(name: pet.name.isEmpty ? "芽芽" : pet.name)
        allTasks = tasks
        unlockedTaskIDs = Set()
        completedTaskIDs = Set()
        lastDialog = nil
        lastOutcomeType = nil
        if let first = tasks.first {
            unlockedTaskIDs.insert(first.id)
            currentTaskID = first.id
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
