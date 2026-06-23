import Foundation
import SwiftUI

/// 宠物成长阶段（基础 4 阶段）+ 成年后无限等级系统
/// 长期陪伴：种子→幼苗→少年→成年→成年 Lv.2→Lv.3→...（无限）
enum PetStage: String, Codable, CaseIterable {
    case seed = "种子"
    case sprout = "幼苗"
    case young = "少年"
    case adult = "成年"

    var next: PetStage? {
        switch self {
        case .seed: return .sprout
        case .sprout: return .young
        case .young: return .adult
        case .adult: return nil
        }
    }

    var minXP: Int {
        switch self {
        case .seed: return 0
        case .sprout: return 30
        case .young: return 80
        case .adult: return 160
        }
    }

    var scale: CGFloat {
        switch self {
        case .seed: return 0.55
        case .sprout: return 0.7
        case .young: return 0.85
        case .adult: return 1.0
        }
    }
}

enum PetMood: String, Codable {
    case neutral
    case happy
    case sleepy
    case encouraging
    case celebrating
    case thoughtful
}

struct PetPersonality: Codable {
    var diligence: Float = 0.5
    var flexibility: Float = 0.5
    var patience: Float = 0.5
    var curiosity: Float = 0.5

    func dominant() -> String {
        let traits: [(String, Float)] = [
            ("勤奋", diligence),
            ("灵活", flexibility),
            ("耐心", patience),
            ("好奇", curiosity)
        ]
        return traits.max(by: { $0.1 < $1.1 })!.0
    }
}

struct Pet: Codable {
    var name: String
    var stage: PetStage = .seed
    /// 成年后的等级（无限延伸）。Lv.0 表示还未到成年， Lv.1+ 表示成年后第 N 级
    var level: Int = 0
    var personality: PetPersonality = PetPersonality()
    var xp: Int = 0
    var mood: PetMood = .neutral
    /// 总共升级（stage + level）的次数，用于触发升级动画
    var totalLevelMilestones: Int = 0

    mutating func gainXP(_ amount: Int) {
        xp += amount
        while let next = stage.next, xp >= next.minXP {
            stage = next
            totalLevelMilestones += 1
        }
        // 成年后每 50 XP +1 级
        if stage == .adult {
            let adultXP = xp - PetStage.adult.minXP
            let newLevel = (adultXP / 50) + 1
            if newLevel > level {
                let gained = newLevel - max(level, 0)
                level = newLevel
                totalLevelMilestones += gained
            }
        }
    }

    /// 展示标签：种子 / 幼苗 / 少年 / 成年 / 成年 Lv.5
    var displayStage: String {
        guard stage == .adult, level > 0 else { return stage.rawValue }
        return "成年 Lv.\(level)"
    }

    mutating func apply(_ delta: PersonalityDelta) {
        personality.diligence = clamp(personality.diligence + delta.diligence)
        personality.flexibility = clamp(personality.flexibility + delta.flexibility)
        personality.patience = clamp(personality.patience + delta.patience)
        personality.curiosity = clamp(personality.curiosity + delta.curiosity)
    }

    private func clamp(_ v: Float) -> Float {
        min(1, max(0, v))
    }
}
