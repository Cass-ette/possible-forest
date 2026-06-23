import Foundation
import SwiftUI

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
    var personality: PetPersonality = PetPersonality()
    var xp: Int = 0
    var mood: PetMood = .neutral

    mutating func gainXP(_ amount: Int) {
        xp += amount
        while let next = stage.next, xp >= next.minXP {
            stage = next
        }
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
