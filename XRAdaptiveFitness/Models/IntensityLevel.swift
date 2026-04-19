import SwiftUI

enum IntensityLevel: String {
    case slow   = "Slow"
    case medium = "Medium"
    case fast   = "Fast"

    // Maps treadmill speed (km/h) to intensity tier
    static func from(speed: Double) -> IntensityLevel {
        switch speed {
        case ..<5:  return .slow
        case ..<10: return .medium
        default:    return .fast
        }
    }

    var speedRange: String {
        switch self {
        case .slow:   return "0–4 km/h"
        case .medium: return "5–9 km/h"
        case .fast:   return "10–15 km/h"
        }
    }

    var icon: String {
        switch self {
        case .slow:   return "🟢"
        case .medium: return "🟡"
        case .fast:   return "🔴"
        }
    }

    var color: Color {
        switch self {
        case .slow:   return .green
        case .medium: return .yellow
        case .fast:   return .red
        }
    }

    // Volume multiplier applied to base audio layers
    var audioVolume: Float {
        switch self {
        case .slow:   return 0.3
        case .medium: return 0.6
        case .fast:   return 1.0
        }
    }

    // Drives visual effects in ImmersiveView
    var visualIntensity: Float {
        switch self {
        case .slow:   return 0.2
        case .medium: return 0.5
        case .fast:   return 1.0
        }
    }
}
