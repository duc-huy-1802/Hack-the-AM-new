import SwiftUI
import RealityKit

/// Full-immersion lollipop candy world.
/// The environment scrolls forward at the user-selected speed so standing/walking
/// in the room feels like moving through the candy forest.
struct ImmersiveView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel

    // Reference to root so we can drive it from the movement loop
    @State private var forestRoot: Entity?

    // Candy palette inspired by the reference image (deep pink / purple dominant)
    private let candyColors: [(Float, Float, Float)] = [
        (0.90, 0.12, 0.55),  // hot fuchsia
        (0.78, 0.05, 0.72),  // deep magenta
        (0.55, 0.04, 0.85),  // deep purple
        (0.95, 0.38, 0.60),  // bubblegum pink
        (0.70, 0.10, 0.50),  // wine pink
        (0.98, 0.55, 0.30),  // coral/orange
        (0.88, 0.20, 0.38),  // raspberry
        (0.60, 0.18, 0.90),  // violet
        (1.00, 0.70, 0.80),  // baby pink
        (0.45, 0.05, 0.65),  // eggplant
    ]

    var body: some View {
        RealityView { content in
            let root = buildScene()
            forestRoot = root
            content.add(root)
        } update: { _ in
            // intensity visual handled in movement loop
        }
        // ── Continuous forward-scroll loop ──────────────────────────────
        .task {
            while !Task.isCancelled {
                if viewModel.isSessionActive, let root = forestRoot {
                    // Convert km/h → immersive m/s (scaled for comfort)
                    let kmh = Float(viewModel.currentSpeed)
                    let immersiveSpeed: Float = (kmh / 15.0) * 2.2  // max ~2.2 m/s scroll

                    if immersiveSpeed > 0 {
                        root.position.z += immersiveSpeed / 60.0

                        // Seamless loop: when root drifts 20 m, snap back
                        if root.position.z > 20.0 {
                            root.position.z -= 20.0
                        }
                    }
                }
                try? await Task.sleep(nanoseconds: 16_666_667) // ~60 fps
            }
        }
    }

    // MARK: - Scene

    private func buildScene() -> Entity {
        let root = Entity()
        root.addChild(makeSky())
        root.addChild(makeGround())

        // ── Lollipop trees — scattered, not rings ─────────────────────
        for i in 0..<160 {
            let s = i * 23 + 7
            let angle = pseudoRandom(s) * .pi * 2
            let dist  = 1.6 + sqrt(pseudoRandom(s + 1)) * 18.0

            let stickH    = 1.8 + pseudoRandom(s + 2) * 2.4
            let candyR    = 0.40 + pseudoRandom(s + 3) * 0.85
            let fog: Float = dist < 9 ? 1.0 : max(0.30, 1.0 - (dist - 9) / 12.0)

            root.addChild(makeLollipop(
                at: [cos(angle) * dist, -1.5, sin(angle) * dist],
                stickHeight: stickH,
                candyRadius: candyR,
                seed: s,
                opacity: fog
            ))
        }

        // ── Candy balls on the ground (like the reference image) ───────
        for i in 0..<70 {
            let s = i * 41 + 999
            let angle = pseudoRandom(s) * .pi * 2
            let dist: Float = 0.8 + pseudoRandom(s + 1) * 12.0
            root.addChild(makeCandyBall(
                at: [cos(angle) * dist, -1.42, sin(angle) * dist],
                seed: s
            ))
        }

        // ── Cotton-candy puffs (small fluffy clusters near user) ───────
        for i in 0..<30 {
            let s = i * 17 + 5000
            let angle = pseudoRandom(s) * .pi * 2
            let dist: Float = 2.0 + pseudoRandom(s + 1) * 6.0
            root.addChild(makeCottonCandy(
                at: [cos(angle) * dist, -1.5, sin(angle) * dist],
                seed: s
            ))
        }

        return root
    }

    // MARK: - Components

    /// Bright sky blue + slight mist (matches reference image)
    private func makeSky() -> Entity {
        var mat = UnlitMaterial()
        mat.color = .init(tint: .init(red: 0.52, green: 0.78, blue: 0.95, alpha: 1))
        let dome = ModelEntity(mesh: .generateSphere(radius: 55), materials: [mat])
        dome.scale = SIMD3<Float>(-1, 1, 1)
        return dome
    }

    /// Mossy green ground (matches reference)
    private func makeGround() -> Entity {
        let ground = ModelEntity(
            mesh: .generatePlane(width: 70, depth: 70),
            materials: [SimpleMaterial(
                color: .init(red: 0.25, green: 0.48, blue: 0.14, alpha: 1),
                isMetallic: false
            )]
        )
        ground.position = [0, -1.5, 0]
        return ground
    }

    /// Lollipop = striped stick + squashed candy sphere
    private func makeLollipop(
        at position: SIMD3<Float>,
        stickHeight: Float,
        candyRadius: Float,
        seed: Int,
        opacity: Float
    ) -> Entity {
        let pop = Entity()

        // ── Striped stick (alternating dark + gold, like reference) ───
        let stripes   = 6
        let stripeH   = stickHeight / Float(stripes)
        for k in 0..<stripes {
            let darkStripe = k % 2 == 0
            let col: UIColor = darkStripe
                ? .init(red: 0.12, green: 0.08, blue: 0.12, alpha: 1)   // near-black
                : .init(red: 0.95, green: 0.75, blue: 0.20, alpha: 1)   // gold
            let seg = ModelEntity(
                mesh: .generateCylinder(height: stripeH, radius: 0.04),
                materials: [SimpleMaterial(color: col, isMetallic: false)]
            )
            seg.position = position + SIMD3(0, Float(k) * stripeH + stripeH / 2, 0)
            pop.addChild(seg)
        }

        // ── Candy sphere (squashed = lollipop candy shape) ─────────────
        let (r, g, b) = pickCandy(seed)
        let candy = ModelEntity(
            mesh: .generateSphere(radius: candyRadius),
            materials: [SimpleMaterial(
                color: .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1),
                isMetallic: false
            )]
        )
        candy.scale = SIMD3<Float>(1.0, 0.78, 1.0)   // squash = lollipop disc shape
        candy.position = position + SIMD3(0, stickHeight + candyRadius * 0.4, 0)

        // Lighter inner highlight to suggest swirl
        let highlight = ModelEntity(
            mesh: .generateSphere(radius: candyRadius * 0.45),
            materials: [SimpleMaterial(
                color: .init(red: min(CGFloat(r) + 0.28, 1),
                             green: min(CGFloat(g) + 0.28, 1),
                             blue: min(CGFloat(b) + 0.28, 1), alpha: 0.7),
                isMetallic: false
            )]
        )
        highlight.scale = SIMD3<Float>(1.0, 0.5, 0.3)  // flat oval = swirl centre
        highlight.position = [0, 0, candyRadius * 0.55]
        candy.addChild(highlight)
        pop.addChild(candy)

        if opacity < 1.0 {
            pop.components[OpacityComponent.self] = OpacityComponent(opacity: opacity)
        }
        return pop
    }

    /// Round candy balls scattered on the ground (like the reference)
    private func makeCandyBall(at position: SIMD3<Float>, seed: Int) -> Entity {
        let size: Float = 0.12 + pseudoRandom(seed) * 0.28
        let (r, g, b) = pickCandy(seed + 33)
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

    /// Fluffy cotton candy on a short stick (orange/pink puff from reference)
    private func makeCottonCandy(at position: SIMD3<Float>, seed: Int) -> Entity {
        let group = Entity()
        let stickH: Float = 0.6 + pseudoRandom(seed) * 0.5

        let stick = ModelEntity(
            mesh: .generateCylinder(height: stickH, radius: 0.025),
            materials: [SimpleMaterial(color: .init(red: 0.9, green: 0.75, blue: 0.2, alpha: 1), isMetallic: false)]
        )
        stick.position = position + SIMD3(0, stickH / 2, 0)

        // Fluffy cluster: 4 overlapping spheres
        let colors: [(Float,Float,Float)] = [(0.98,0.55,0.28),(0.95,0.70,0.85),(0.85,0.45,0.80),(0.98,0.40,0.55)]
        let baseR: Float = 0.20 + pseudoRandom(seed + 1) * 0.15
        let offsets: [SIMD3<Float>] = [[0,0,0],[baseR*0.5,baseR*0.4,0],[-baseR*0.4,baseR*0.35,baseR*0.2],[0,baseR*0.6,-baseR*0.3]]
        for (j, off) in offsets.enumerated() {
            let (cr, cg, cb) = colors[j % colors.count]
            let puff = ModelEntity(
                mesh: .generateSphere(radius: baseR * (0.8 + pseudoRandom(seed + j + 10) * 0.4)),
                materials: [SimpleMaterial(color: .init(red: CGFloat(cr), green: CGFloat(cg), blue: CGFloat(cb), alpha: 1), isMetallic: false)]
            )
            puff.position = position + SIMD3(0, stickH + baseR, 0) + off
            group.addChild(puff)
        }
        group.addChild(stick)
        return group
    }

    // MARK: - Helpers

    private func pickCandy(_ seed: Int) -> (Float, Float, Float) {
        let idx = Int(pseudoRandom(seed + 500) * Float(candyColors.count)) % candyColors.count
        return candyColors[idx]
    }

    private func pseudoRandom(_ n: Int) -> Float {
        let x = sin(Float(n) * 127.1 + 311.7) * 43758.5453
        return x - floor(x)
    }
}
