import Foundation

enum FitnessEnvironment: String, CaseIterable, Identifiable {
    case forest = "Forest"
    case beach  = "Beach"
    case city   = "City"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .forest: return "🍭"
        case .beach:  return "🌊"
        case .city:   return "🌆"
        }
    }

    var description: String {
        switch self {
        case .forest: return "Candy lollipop world"
        case .beach:  return "Ocean shoreline"
        case .city:   return "Urban marathon"
        }
    }

    /// nil = always unlocked. Otherwise, cumulative metres required.
    var unlockMetres: Double? {
        switch self {
        case .forest: return nil
        case .beach:  return 50
        case .city:   return 200
        }
    }

    var baseAudioFiles: [String] {
        switch self {
        case .forest: return ["forest_birds", "forest_wind", "forest_leaves"]
        case .beach:  return ["beach_waves", "beach_wind", "beach_seagulls"]
        case .city:   return ["city_traffic", "city_crowd", "city_ambient"]
        }
    }

    var intensityAudioFile: String {
        switch self {
        case .forest: return "forest_intensity"
        case .beach:  return "beach_intensity"
        case .city:   return "city_intensity"
        }
    }
}
