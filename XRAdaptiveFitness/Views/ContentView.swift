import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @State private var isPanelCollapsed = false

    var body: some View {
        ZStack {
            if isPanelCollapsed {
                // Minimised HUD — tap to expand
                collapsedHUD
            } else {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            EnvironmentPickerView()
                            if viewModel.isSessionActive {
                                SessionView(isCollapsed: $isPanelCollapsed)
                            } else {
                                startButton
                            }
                        }
                        .padding(24)
                    }
                    .navigationTitle("XR Adaptive Fitness")
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPanelCollapsed)
    }

    // MARK: - Start button

    private var startButton: some View {
        Button {
            Task {
                await openImmersiveSpace(id: "ForestImmersive")
                viewModel.isImmersiveSpaceOpen = true
                viewModel.startSession()
                // Auto-collapse after 2 seconds so the forest fills the view
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation { isPanelCollapsed = true }
            }
        } label: {
            Label("Start Walking", systemImage: "figure.walk")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .disabled(!viewModel.isUnlocked(viewModel.selectedEnvironment))
    }

    // MARK: - Collapsed HUD

    private var collapsedHUD: some View {
        VStack(spacing: 12) {
            // Speed + timer at a glance
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text(viewModel.intensity.icon).font(.title)
                    Text(String(format: "%.1f", viewModel.currentSpeed))
                        .font(.title2.bold().monospacedDigit())
                    Text("km/h").font(.caption2).foregroundStyle(.secondary)
                }
                Divider().frame(height: 50)
                VStack(spacing: 2) {
                    Image(systemName: "timer").font(.title2).foregroundStyle(.secondary)
                    Text(formattedTime)
                        .font(.title2.monospacedDigit())
                    Text("elapsed").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Speed slider (still accessible when collapsed)
            HStack {
                Image(systemName: "tortoise").foregroundStyle(.secondary)
                Slider(
                    value: Binding(
                        get: { viewModel.currentSpeed },
                        set: { viewModel.setSpeed($0) }
                    ),
                    in: 0...15, step: 0.5
                )
                .tint(viewModel.intensity.color)
                Image(systemName: "hare").foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Button {
                withAnimation { isPanelCollapsed = false }
            } label: {
                Label("Show Controls", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: 340)
    }

    private var formattedTime: String {
        let m = Int(viewModel.elapsedTime) / 60
        let s = Int(viewModel.elapsedTime) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
