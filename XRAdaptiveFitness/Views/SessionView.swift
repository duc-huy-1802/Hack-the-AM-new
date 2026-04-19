import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 20) {

            // Top bar: environment + timer
            HStack {
                Label(viewModel.selectedEnvironment.rawValue, systemImage: "leaf.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                    Text(formattedTime)
                        .monospacedDigit()
                }
                .font(.headline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)

            Divider()

            // Speed ring
            ZStack {
                // Track
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 14)
                    .frame(width: 160, height: 160)

                // Fill
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.currentSpeed / 15.0))
                    .stroke(
                        AngularGradient(
                            colors: [.green, .yellow, .orange, .red],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: viewModel.currentSpeed)

                // Center text
                VStack(spacing: 2) {
                    Text(viewModel.intensity.icon)
                        .font(.title2)
                    Text(String(format: "%.1f", viewModel.currentSpeed))
                        .font(.system(size: 32, weight: .bold, design: .rounded).monospacedDigit())
                    Text("km/h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Intensity label
            HStack(spacing: 6) {
                Text(viewModel.intensity.rawValue)
                    .font(.title3.bold())
                    .foregroundStyle(viewModel.intensity.color)
                Text("·")
                    .foregroundStyle(.secondary)
                Text(viewModel.intensity.speedRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Speed slider
            VStack(spacing: 6) {
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
                    Text("Slow").font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    Text("Fast").font(.caption2).foregroundStyle(.secondary)
                }
            }

            Divider()

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
                    .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var formattedTime: String {
        let m = Int(viewModel.elapsedTime) / 60
        let s = Int(viewModel.elapsedTime) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
