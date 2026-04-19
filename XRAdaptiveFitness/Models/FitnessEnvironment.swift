import Foundation

enum FitnessEnvironment: String, CaseIterable, Identifiable {
    case forest = "Forest"
    case beach  = "Beach"
    case city   = "City"

    var id: String { rawValue }

    var isAvailable: Bool {
        self == .forest
    }

    var icon: String {
        switch self {
        case .forest: return "🌲"
        case .beach:  return "🌊"
        case .city:   return "🌆"
        }
    }

    var description: String {
        switch self {
        case .forest: return "Dense nature environment"
        case .beach:  return "Ocean shoreline environment"
        case .city:   return "Urban marathon environment"
        }
    }

    // Base looping audio files — add these .mp3s to your Xcode bundle
    var baseAudioFiles: [String] {
        switch self {
        case .forest: return ["forest_birds", "forest_wind", "forest_leaves"]
        case .beach:  return ["beach_waves", "beach_wind", "beach_seagulls"]
        case .city:   return ["city_traffic", "city_crowd", "city_ambient"]
        }
    }

    // Extra layer played at fast intensity
    var intensityAudioFile: String {
        switch self {
        case .forest: return "forest_intensity"
        case .beach:  return "beach_intensity"
        case .city:   return "city_intensity"
        }
    }
}
