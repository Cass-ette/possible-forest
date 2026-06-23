import Foundation
import SwiftUI

enum TaskCategory: String, Codable, CaseIterable {
    case study = "学习"
    case work = "工作"
    case life = "生活"
    case health = "健康"

    var icon: String {
        switch self {
        case .study: return "book.closed.fill"
        case .work: return "briefcase.fill"
        case .life: return "cup.and.saucer.fill"
        case .health: return "leaf.fill"
        }
    }

    var tint: Color {
        switch self {
        case .study: return Color(hex: 0x6E84FF)
        case .work: return Color(hex: 0xB57BFF)
        case .life: return Color(hex: 0xFF9F6B)
        case .health: return Color(hex: 0x5BCB8B)
        }
    }
}

enum OutcomeType: String, Codable {
    case perfect
    case partial
    case abandon

    var label: String {
        switch self {
        case .perfect: return "完成"
        case .partial: return "部分完成"
        case .abandon: return "改天吧"
        }
    }

    var icon: String {
        switch self {
        case .perfect: return "checkmark.circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .abandon: return "moon.zzz.fill"
        }
    }
}

struct PersonalityDelta: Codable, Equatable {
    var diligence: Float = 0
    var flexibility: Float = 0
    var patience: Float = 0
    var curiosity: Float = 0

    static let perfect = PersonalityDelta(diligence: 0.08, patience: 0.03)
    static let partial = PersonalityDelta(flexibility: 0.06, patience: 0.05)
    static let abandon = PersonalityDelta(flexibility: 0.07, patience: -0.02, curiosity: 0.05)
}

struct TaskOutcome: Codable, Identifiable {
    var id: UUID = UUID()
    let type: OutcomeType
    let petDialog: String
    let unlockTaskIDs: [UUID]
    let personalityDelta: PersonalityDelta
    let xpGain: Int
}

struct TaskNode: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var category: TaskCategory
    var icon: String?
    var day: Int
    var outcomes: [OutcomeType: TaskOutcome]
    var isCompleted: Bool
    var chosenOutcome: OutcomeType?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        category: TaskCategory,
        icon: String? = nil,
        day: Int = 1,
        outcomes: [OutcomeType: TaskOutcome]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.icon = icon
        self.day = day
        self.outcomes = outcomes
        self.isCompleted = false
        self.chosenOutcome = nil
    }

    func outcome(for type: OutcomeType) -> TaskOutcome? {
        outcomes[type]
    }
}
