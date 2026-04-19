import AVFoundation

/// Manages looping spatial audio layers.
/// Base layers run continuously; an intensity layer is added/removed at fast speed.
class SpatialAudioManager {
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private var basePlayers: [AVAudioPlayerNode] = []
    private var intensityPlayer: AVAudioPlayerNode?

    init() {
        engine.attach(environment)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }

    // MARK: - Public

    func startEnvironment(_ env: FitnessEnvironment) {
        stopAll()
        for fileName in env.baseAudioFiles {
            addLoopingPlayer(file: fileName)
        }
    }

    func updateIntensity(_ intensity: IntensityLevel, for env: FitnessEnvironment) {
        basePlayers.forEach { $0.volume = intensity.audioVolume }

        if intensity == .fast {
            if intensityPlayer == nil {
                intensityPlayer = addLoopingPlayer(file: env.intensityAudioFile)
            }
        } else {
            removeIntensityPlayer()
        }
    }

    func stopAll() {
        (basePlayers + [intensityPlayer].compactMap { $0 }).forEach { player in
            player.stop()
            engine.detach(player)
        }
        basePlayers.removeAll()
        intensityPlayer = nil
    }

    // MARK: - Private

    @discardableResult
    private func addLoopingPlayer(file: String) -> AVAudioPlayerNode? {
        guard
            let url      = Bundle.main.url(forResource: file, withExtension: "mp3"),
            let audioFile = try? AVAudioFile(forReading: url),
            let buffer   = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ),
            (try? audioFile.read(into: buffer)) != nil
        else {
            print("[Audio] Missing file: \(file).mp3 — add it to the Xcode bundle")
            return nil
        }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: environment, format: buffer.format)
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.play()
        basePlayers.append(player)
        return player
    }

    private func removeIntensityPlayer() {
        guard let player = intensityPlayer else { return }
        player.stop()
        engine.detach(player)
        basePlayers.removeAll { $0 === player }
        intensityPlayer = nil
    }
}
