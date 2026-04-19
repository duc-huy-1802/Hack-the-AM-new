import SwiftUI

@main
struct XRAdaptiveFitnessApp: App {
    @StateObject private var viewModel = FitnessSessionViewModel()

    var body: some Scene {
        // 2D control panel window
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }

        // Full XR immersive forest scene
        ImmersiveSpace(id: "ForestImmersive") {
            ImmersiveView()
                .environmentObject(viewModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
