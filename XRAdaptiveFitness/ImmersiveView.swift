import SwiftUI
import RealityKit

/// Lollipop forest — candy-coloured trees, dreamy purple sky, soft lavender ground.
struct ImmersiveView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel

    // Candy palette — picked per tree via pseudo-random
    private let candyColors: [(Float, Float, Float)] = [
        (1.00, 0.20, 0.55),   // hot pink
        (0.88, 0.08, 0.72),   // magenta
        (0.62, 0.08, 0.92),   // deep purple
        (1.00, 0.42, 0.28),   // coral
        (0.18, 0.88, 0.62),   // mint
        (1.00, 0.90, 0.15),   // lemon
        (0.40, 0.65, 1.00),   // sky blue
        (0.85, 0.55, 1.00),   // lavender
        (1.00, 0.55, 0.80),   // baby pink
        (0.30, 1.00, 0.80),   // aqua
    ]

    var body: some View {
        RealityView { content in
            content.add(buildForest())
        } update: { content in
            applyIntensity(viewModel.intensity, to: content)
        }
    }

    // MARK: - Forest

    private func buildForest() -> Entity {
        let root = Entity()
        root.addChild(makeSkyDome())
        root.addChild(makeGround())

        // 180 lollipop trees scattered randomly from 1.8m to 20m
        for i in 0..<180 {
            let s = i * 23 + 7
            let angle = pseudoRandom(s) * .pi * 2
            let dist  = 1.8 + sqrt(pseudoRandom(s + 1)) * 18.2

            let x = cos(angle) * dist
            let z = sin(angle) * dist

            let trunkHeight   = 1.4 + pseudoRandom(s + 2) * 2.0
            let candyRadius   = 0.45 + pseudoRandom(s + 3) * 0.75
            let fogOpacity: Float = dist < 10 ? 1.0 : max(0.35, 1.0 - (dist - 10) / 12.0)

            root.addChild(makeLollipop(
                at: [x, -1.5, z],
                stickHeight: trunkHeight,
                candyRadius: candyRadius,
                seed: s,
                opacity: fogOpacity
            ))
        }

        // Colourful puffball bushes close to user (1–5m)
        for i in 0..<80 {
            let s = i * 41 + 999
            let angle = pseudoRandom(s) * .pi * 2
            let dist: Float = 1.0 + pseudoRandom(s + 1) * 4.0
            root.addChild(makePuffball(
                at: [cos(angle) * dist, -1.38, sin(angle) * dist],
                seed: s
            ))
        }

        return root
    }

    // MARK: - Components

    /// Purple-pink sky — feels like a magical candy world
    private func makeSkyDome() -> Entity {
        var mat = UnlitMaterial()
        mat.color = .init(tint: .init(red: 0.28, green: 0.04, blue: 0.38, alpha: 1))
        let dome = ModelEntity(mesh: .generateSphere(radius: 50), materials: [mat])
        dome.scale = SIMD3<Float>(-1, 1, 1)
        return dome
    }

    /// Soft lavender ground
    private func makeGround() -> Entity {
        let ground = ModelEntity(
            mesh: .generatePlane(width: 70, depth: 70),
            materials: [SimpleMaterial(
                color: .init(red: 0.78, green: 0.60, blue: 0.90, alpha: 1),
                isMetallic: false
            )]
        )
        ground.position = [0, -1.5, 0]
        return ground
    }

    /// A lollipop tree: thin white stick + big candy sphere on top
    private func makeLollipop(
        at position: SIMD3<Float>,
        stickHeight: Float,
        candyRadius: Float,
        seed: Int,
        opacity: Float
    ) -> Entity {
        let tree = Entity()

        // White/cream stick (lollipop handle)
        let stick = ModelEntity(
            mesh: .generateCylinder(height: stickHeight, radius: 0.04),
            materials: [SimpleMaterial(
                color: .init(red: 0.95, green: 0.92, blue: 0.95, alpha: 1),
                isMetallic: false
            )]
        )
        stick.position = position + SIMD3(0, stickHeight / 2, 0)

        // Candy sphere — pick colour from palette
        let (r, g, b) = pickCandy(seed: seed)
        let candy = ModelEntity(
            mesh: .generateSphere(radius: candyRadius),
            materials: [SimpleMaterial(
                color: .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1),
                isMetallic: false
            )]
        )
        // Squash slightly so it looks like a real lollipop candy
        candy.scale = SIMD3<Float>(1.0, 0.82, 1.0)
        candy.position = [0, stickHeight / 2 + candyRadius * 0.55, 0]
        stick.addChild(candy)
        tree.addChild(stick)

        if opacity < 1.0 {
            tree.components[OpacityComponent.self] = OpacityComponent(opacity: opacity)
        }
        return tree
    }

    /// Small colourful puffball near the ground
    private func makePuffball(at position: SIMD3<Float>, seed: Int) -> Entity {
        let size: Float = 0.10 + pseudoRandom(seed) * 0.22
        let (r, g, b) = pickCandy(seed: seed + 77)
        let ball = ModelEntity(
            mesh: .generateSphere(radius: size),
            materials: [SimpleMaterial(
                color: .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1),
                isMetallic: false
            )]
        )
        ball.position = position
        return ball
    }

    // MARK: - Helpers

    private func pickCandy(seed: Int) -> (Float, Float, Float) {
        let idx = Int(pseudoRandom(seed + 500) * Float(candyColors.count)) % candyColors.count
        return candyColors[idx]
    }

    private func pseudoRandom(_ n: Int) -> Float {
        let x = sin(Float(n) * 127.1 + 311.7) * 43758.5453
        return x - floor(x)
    }

    // MARK: - Intensity

    private func applyIntensity(_ intensity: IntensityLevel, to content: RealityViewContent) {
        let boost: Float = 0.7 + intensity.visualIntensity * 0.3
        for entity in content.entities {
            if entity.components[OpacityComponent.self] == nil {
                entity.components[OpacityComponent.self] = OpacityComponent(opacity: boost)
            }
        }
    }
}
