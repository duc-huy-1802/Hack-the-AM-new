import Foundation
import Combine

@MainActor
class FitnessSessionViewModel: ObservableObject {
    @Published var selectedEnvironment: FitnessEnvironment = .forest
    @Published var currentSpeed: Double = 0.0
    @Published var isSessionActive: Bool = false
    @Published var isImmersiveSpaceOpen: Bool = false

    private let audioManager = SpatialAudioManager()
    private var cancellables = Set<AnyCancellable>()

    // Derived from speed — no separate storage needed
    var intensity: IntensityLevel {
        IntensityLevel.from(speed: currentSpeed)
    }

    init() {
        // Only update audio when the intensity tier actually changes
        $currentSpeed
            .map { IntensityLevel.from(speed: $0) }
            .removeDuplicates { $0.rawValue == $1.rawValue }
            .sink { [weak self] newIntensity in
                guard let self, self.isSessionActive else { return }
                self.audioManager.updateIntensity(newIntensity, for: self.selectedEnvironment)
            }
            .store(in: &cancellables)
    }

    func startSession() {
        isSessionActive = true
        audioManager.startEnvironment(selectedEnvironment)
        audioManager.updateIntensity(intensity, for: selectedEnvironment)
    }

    func stopSession() {
        isSessionActive = false
        currentSpeed = 0.0
        audioManager.stopAll()
    }

    func selectEnvironment(_ env: FitnessEnvironment) {
        guard env.isAvailable else { return }
        selectedEnvironment = env
        if isSessionActive {
            audioManager.startEnvironment(env)
            audioManager.updateIntensity(intensity, for: env)
        }
    }

    // Called by the slider or a real treadmill data source
    func setSpeed(_ speed: Double) {
        currentSpeed = max(0, min(speed, 15))
    }
}
