import SwiftUI
import RealityKit

/// Full-immersion XR forest. The real room disappears — user walks inside a forest.
/// Vision Pro tracks physical movement so the user naturally walks through the scene.
struct ImmersiveView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel

    var body: some View {
        RealityView { content in
            content.add(buildForest())
        } update: { content in
            applyIntensity(viewModel.intensity, to: content)
        }
    }

    // MARK: - Forest Scene Builder

    private func buildForest() -> Entity {
        let root = Entity()
        root.addChild(makeSkyDome())
        root.addChild(makeGround())
        root.addChild(makeTreeRing(count: 8,  radius: 4,  trunkHeight: 2.0, canopySize: 0.8))
        root.addChild(makeTreeRing(count: 14, radius: 8,  trunkHeight: 3.0, canopySize: 1.2))
        root.addChild(makeTreeRing(count: 20, radius: 14, trunkHeight: 4.5, canopySize: 1.8))
        root.addChild(makeBushRing(count: 12, radius: 3))
        return root
    }

    // MARK: - Scene Components

    /// Large inverted sphere — gives the forest a green sky/canopy feel
    private func makeSkyDome() -> Entity {
        var material = UnlitMaterial()
        material.color = .init(tint: .init(red: 0.15, green: 0.35, blue: 0.15, alpha: 1))
        let dome = ModelEntity(mesh: .generateSphere(radius: 50), materials: [material])
        dome.scale = SIMD3<Float>(-1, 1, 1)
        return dome
    }

    /// Large flat ground — green-brown forest floor
    private func makeGround() -> Entity {
        let ground = ModelEntity(
            mesh: .generatePlane(width: 60, depth: 60),
            materials: [SimpleMaterial(
                color: .init(red: 0.22, green: 0.38, blue: 0.15, alpha: 1),
                isMetallic: false
            )]
        )
        ground.position = [0, -1.5, 0]
        return ground
    }

    /// Ring of trees at a given radius
    private func makeTreeRing(count: Int, radius: Float, trunkHeight: Float, canopySize: Float) -> Entity {
        let ring = Entity()
        for i in 0..<count {
            let angle = Float(i) * (.pi * 2 / Float(count))
            let radiusVariation = radius + Float(i % 3) * 0.6 - 0.3
            let x = cos(angle) * radiusVariation
            let z = sin(angle) * radiusVariation
            ring.addChild(makeTree(
                at: [x, -1.5, z],
                trunkHeight: trunkHeight + Float(i % 3) * 0.4,
                canopyRadius: canopySize + Float(i % 2) * 0.2
            ))
        }
        return ring
    }

    private func makeTree(at position: SIMD3<Float>, trunkHeight: Float, canopyRadius: Float) -> Entity {
        let tree = Entity()

        let trunk = ModelEntity(
            mesh: .generateCylinder(height: trunkHeight, radius: 0.12),
            materials: [SimpleMaterial(
                color: .init(red: 0.35, green: 0.22, blue: 0.10, alpha: 1),
                isMetallic: false
            )]
        )
        trunk.position = position + SIMD3(0, trunkHeight / 2, 0)

        let canopy = ModelEntity(
            mesh: .generateSphere(radius: canopyRadius),
            materials: [SimpleMaterial(
                color: .init(red: 0.08, green: 0.40, blue: 0.10, alpha: 1),
                isMetallic: false
            )]
        )
        canopy.position = [0, trunkHeight / 2 + canopyRadius * 0.6, 0]
        trunk.addChild(canopy)
        tree.addChild(trunk)
        return tree
    }

    /// Low bushes near the user for depth
    private func makeBushRing(count: Int, radius: Float) -> Entity {
        let ring = Entity()
        for i in 0..<count {
            let angle = Float(i) * (.pi * 2 / Float(count)) + 0.3
            let r = radius + Float(i % 4) * 0.5
            let bush = ModelEntity(
                mesh: .generateSphere(radius: 0.35 + Float(i % 3) * 0.1),
                materials: [SimpleMaterial(
                    color: .init(red: 0.10, green: 0.32, blue: 0.08, alpha: 1),
                    isMetallic: false
                )]
            )
            bush.position = [cos(angle) * r, -1.2, sin(angle) * r]
            ring.addChild(bush)
        }
        return ring
    }

    // MARK: - Intensity visual update

    private func applyIntensity(_ intensity: IntensityLevel, to content: RealityViewContent) {
        // Fix: OpacityComponent takes Float, not Double
        let opacity: Float = 0.65 + intensity.visualIntensity * 0.35
        for entity in content.entities {
            entity.components[OpacityComponent.self] = OpacityComponent(opacity: opacity)
        }
    }
}
