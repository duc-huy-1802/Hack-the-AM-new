import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 20) {

            // Live intensity status
            HStack(spacing: 12) {
                Text(viewModel.intensity.icon).font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.intensity.rawValue)
                        .font(.title2.bold())
                        .foregroundStyle(viewModel.intensity.color)
                    Text(viewModel.intensity.speedRange)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(String(format: "%.1f km/h", viewModel.currentSpeed))
                    .font(.title.monospacedDigit())
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Speed slider (demo / manual override)
            VStack(alignment: .leading, spacing: 6) {
                Text("Speed").font(.headline)
                Slider(
                    value: Binding(
                        get: { viewModel.currentSpeed },
                        set: { viewModel.setSpeed($0) }
                    ),
                    in: 0...15,
                    step: 0.5
                )
                .tint(viewModel.intensity.color)

                HStack {
                    Text("0").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text("15 km/h").font(.caption).foregroundStyle(.secondary)
                }
            }

            // End session
            Button(role: .destructive) {
                Task {
                    viewModel.stopSession()
                    await dismissImmersiveSpace()
                    viewModel.isImmersiveSpaceOpen = false
                }
            } label: {
                Label("End Session", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
    }
}
