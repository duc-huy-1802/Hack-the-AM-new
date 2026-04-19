import Foundation
import Combine

@MainActor
class FitnessSessionViewModel: ObservableObject {
    @Published var selectedEnvironment: FitnessEnvironment = .forest
    @Published var currentSpeed: Double = 0.0
    @Published var isSessionActive: Bool = false
    @Published var isImmersiveSpaceOpen: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var totalMetres: Double = 0          // cumulative across all sessions
    @Published var sessionMetres: Double = 0        // this session only

    private let audioManager = SpatialAudioManager()
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private var sessionStartTime: Date?

    // MARK: - Derived

    var intensity: IntensityLevel {
        IntensityLevel.from(speed: currentSpeed)
    }

    func isUnlocked(_ env: FitnessEnvironment) -> Bool {
        guard let req = env.unlockMetres else { return true }
        return totalMetres >= req
    }

    func metresNeeded(for env: FitnessEnvironment) -> Double {
        guard let req = env.unlockMetres else { return 0 }
        return max(0, req - totalMetres)
    }

    // MARK: - Session lifecycle

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
        sessionMetres = 0
        elapsedTime = 0
        sessionStartTime = Date()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let start = self.sessionStartTime else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
                // Accumulate distance: speed km/h ÷ 3.6 = m/s, × 1 second
                let metresThisTick = self.currentSpeed / 3.6
                self.sessionMetres += metresThisTick
                self.totalMetres  += metresThisTick
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
        sessionMetres = 0
        audioManager.stopAll()
    }

    func selectEnvironment(_ env: FitnessEnvironment) {
        guard isUnlocked(env) else { return }
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
