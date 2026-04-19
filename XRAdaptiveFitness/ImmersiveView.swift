import SwiftUI
import RealityKit

/// Full-immersion XR forest.
/// Trees are scattered naturally (not in rings) so walking in ANY direction
/// always keeps you surrounded by forest. Vision Pro tracks real movement.
struct ImmersiveView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel

    var body: some View {
        RealityView { content in
            content.add(buildForest())
        } update: { content in
            applyIntensity(viewModel.intensity, to: content)
        }
    }

    // MARK: - Forest Builder

    private func buildForest() -> Entity {
        let root = Entity()
        root.addChild(makeSkyDome())
        root.addChild(makeGround())

        // 180 trees scattered randomly from 1.8m – 20m in every direction.
        // sqrt distribution = uniform coverage (avoids crowding near center)
        for i in 0..<180 {
            let s = i * 23 + 7
            let angle = pseudoRandom(s) * .pi * 2
            let minDist: Float = 1.8
            let maxDist: Float = 20.0
            let dist = minDist + sqrt(pseudoRandom(s + 1)) * (maxDist - minDist)

            let x = cos(angle) * dist
            let z = sin(angle) * dist

            // Trees get taller + wider the further away (more imposing forest wall)
            let trunkHeight = 1.6 + pseudoRandom(s + 2) * 1.8 + dist * 0.08
            let canopyRadius = 0.5 + pseudoRandom(s + 3) * 0.9 + dist * 0.02

            // Distance fog: trees beyond 10m fade slightly
            let fogOpacity: Float = dist < 10 ? 1.0 : max(0.4, 1.0 - (dist - 10) / 14.0)

            root.addChild(makeTree(
                at: [x, -1.5, z],
                trunkHeight: trunkHeight,
                canopyRadius: canopyRadius,
                seed: s,
                opacity: fogOpacity
            ))
        }

        // Dense undergrowth 1–5m from user — makes you feel immediately inside forest
        for i in 0..<80 {
            let s = i * 41 + 999
            let angle = pseudoRandom(s) * .pi * 2
            let dist: Float = 1.0 + pseudoRandom(s + 1) * 4.5
            let x = cos(angle) * dist
            let z = sin(angle) * dist
            root.addChild(makeBush(at: [x, -1.38, z], seed: s))
        }

        return root
    }

    // MARK: - Components

    private func makeSkyDome() -> Entity {
        var mat = UnlitMaterial()
        // Dark forest canopy green — not bright blue (you're under tree cover)
        mat.color = .init(tint: .init(red: 0.06, green: 0.18, blue: 0.06, alpha: 1))
        let dome = ModelEntity(mesh: .generateSphere(radius: 50), materials: [mat])
        dome.scale = SIMD3<Float>(-1, 1, 1)  // flip inside-out
        return dome
    }

    private func makeGround() -> Entity {
        let ground = ModelEntity(
            mesh: .generatePlane(width: 70, depth: 70),
            materials: [SimpleMaterial(
                color: .init(red: 0.16, green: 0.28, blue: 0.09, alpha: 1),
                isMetallic: false
            )]
        )
        ground.position = [0, -1.5, 0]
        return ground
    }

    private func makeTree(
        at position: SIMD3<Float>,
        trunkHeight: Float,
        canopyRadius: Float,
        seed: Int,
        opacity: Float
    ) -> Entity {
        let tree = Entity()

        // Vary trunk colour slightly per tree
        let tv = pseudoRandom(seed + 100) * 0.07
        let trunk = ModelEntity(
            mesh: .generateCylinder(height: trunkHeight, radius: 0.08 + pseudoRandom(seed + 200) * 0.07),
            materials: [SimpleMaterial(
                color: .init(red: 0.26 + tv, green: 0.15 + tv, blue: 0.06, alpha: 1),
                isMetallic: false
            )]
        )
        trunk.position = position + SIMD3(0, trunkHeight / 2, 0)

        // Vary canopy green
        let gv = pseudoRandom(seed + 300) * 0.14
        let canopy = ModelEntity(
            mesh: .generateSphere(radius: canopyRadius),
            materials: [SimpleMaterial(
                color: .init(red: 0.04 + gv * 0.4, green: 0.28 + gv, blue: 0.04, alpha: 1),
                isMetallic: false
            )]
        )
        canopy.position = [0, trunkHeight / 2 + canopyRadius * 0.42, 0]
        trunk.addChild(canopy)
        tree.addChild(trunk)

        // Distance fog
        if opacity < 1.0 {
            tree.components[OpacityComponent.self] = OpacityComponent(opacity: opacity)
        }

        return tree
    }

    private func makeBush(at position: SIMD3<Float>, seed: Int) -> Entity {
        let size: Float = 0.10 + pseudoRandom(seed) * 0.25
        let gv = pseudoRandom(seed + 1) * 0.10
        let bush = ModelEntity(
            mesh: .generateSphere(radius: size),
            materials: [SimpleMaterial(
                color: .init(red: 0.05, green: 0.22 + gv, blue: 0.04, alpha: 1),
                isMetallic: false
            )]
        )
        bush.position = position
        return bush
    }

    // MARK: - Deterministic pseudo-random (no import needed, no seed state)

    private func pseudoRandom(_ n: Int) -> Float {
        let x = sin(Float(n) * 127.1 + 311.7) * 43758.5453
        return x - floor(x)  // always 0.0 – 1.0
    }

    // MARK: - Intensity visual update

    private func applyIntensity(_ intensity: IntensityLevel, to content: RealityViewContent) {
        let boost: Float = 0.7 + intensity.visualIntensity * 0.3
        for entity in content.entities {
            // Only override entities that don't already have distance fog
            if entity.components[OpacityComponent.self] == nil {
                entity.components[OpacityComponent.self] = OpacityComponent(opacity: boost)
            }
        }
    }
}
