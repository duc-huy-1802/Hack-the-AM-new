import Foundation
import Combine

@MainActor
class FitnessSessionViewModel: ObservableObject {
    @Published var selectedEnvironment: FitnessEnvironment = .forest
    @Published var currentSpeed: Double = 0.0
    @Published var isSessionActive: Bool = false
    @Published var isImmersiveSpaceOpen: Bool = false
    @Published var elapsedTime: TimeInterval = 0

    private let audioManager = SpatialAudioManager()
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private var sessionStartTime: Date?

    var intensity: IntensityLevel {
        IntensityLevel.from(speed: currentSpeed)
    }

    init() {
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
        elapsedTime = 0
        sessionStartTime = Date()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let start = self.sessionStartTime else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }

        audioManager.startEnvironment(selectedEnvironment)
        audioManager.updateIntensity(intensity, for: selectedEnvironment)
    }

    func stopSession() {
        isSessionActive = false
        currentSpeed = 0.0
        timerCancellable?.cancel()
        timerCancellable = nil
        sessionStartTime = nil
        elapsedTime = 0
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

    func setSpeed(_ speed: Double) {
        currentSpeed = max(0, min(speed, 15))
    }
}
