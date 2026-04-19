import SwiftUI
import RealityKit

/// Full XR forest scene. Visuals update whenever intensity changes.
struct ImmersiveView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel

    var body: some View {
        RealityView { content in
            content.add(makeForestScene())
        } update: { content in
            applyIntensity(viewModel.intensity, to: content)
        }
    }

    // MARK: - Procedural Forest Scene

    private func makeForestScene() -> Entity {
        let root = Entity()

        // Ground plane
        let ground = ModelEntity(
            mesh: .generatePlane(width: 20, depth: 20),
            materials: [SimpleMaterial(
                color: .init(red: 0.18, green: 0.42, blue: 0.18, alpha: 1),
                isMetallic: false
            )]
        )
        ground.position = [0, -1.6, 0]
        root.addChild(ground)

        // Ring of trees around the user
        for i in 0..<10 {
            let angle  = Float(i) * (.pi * 2 / 10)
            let radius: Float = 6
            root.addChild(makeTree(at: [cos(angle) * radius, -1.5, sin(angle) * radius]))
        }

        return root
    }

    private func makeTree(at position: SIMD3<Float>) -> Entity {
        let tree = Entity()

        let trunk = ModelEntity(
            mesh: .generateCylinder(height: 2.2, radius: 0.14),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )
        trunk.position = position + SIMD3(0, 1.1, 0)

        let canopy = ModelEntity(
            mesh: .generateSphere(radius: 0.9),
            materials: [SimpleMaterial(
                color: .init(red: 0.08, green: 0.38, blue: 0.08, alpha: 1),
                isMetallic: false
            )]
        )
        canopy.position = [0, 1.4, 0]
        trunk.addChild(canopy)
        tree.addChild(trunk)
        return tree
    }

    // MARK: - Intensity visual update

    private func applyIntensity(_ intensity: IntensityLevel, to content: RealityViewContent) {
        // Boost scene brightness/opacity as speed increases
        let opacity = Double(0.6 + intensity.visualIntensity * 0.4)
        for entity in content.entities {
            entity.components[OpacityComponent.self] = OpacityComponent(opacity: opacity)
        }
    }
}
