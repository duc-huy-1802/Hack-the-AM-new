import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    EnvironmentPickerView()

                    if viewModel.isSessionActive {
                        SessionView()
                    } else {
                        startButton
                    }
                }
                .padding(28)
            }
            .navigationTitle("XR Adaptive Fitness")
        }
    }

    private var startButton: some View {
        Button {
            Task {
                await openImmersiveSpace(id: "ForestImmersive")
                viewModel.isImmersiveSpaceOpen = true
                viewModel.startSession()
            }
        } label: {
            Label("Start Session", systemImage: "figure.run")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.selectedEnvironment.isAvailable)
    }
}
