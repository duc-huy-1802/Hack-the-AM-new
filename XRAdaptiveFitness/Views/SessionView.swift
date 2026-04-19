import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Binding var isCollapsed: Bool

    var body: some View {
        VStack(spacing: 16) {

            // Header row
            HStack {
                Label(viewModel.selectedEnvironment.rawValue, systemImage: "leaf.fill")
                    .font(.headline).foregroundStyle(.purple)
                Spacer()
                Text(formattedTime)
                    .font(.headline.monospacedDigit()).foregroundStyle(.secondary)
                // Collapse button — hides this panel so the forest is fully visible
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { isCollapsed = true }
                } label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.headline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
            }

            Divider()

            // Speed ring
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 14)
                    .frame(width: 150, height: 150)
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.currentSpeed / 15.0))
                    .stroke(
                        AngularGradient(
                            colors: [.mint, .yellow, .orange, .pink, .purple],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: viewModel.currentSpeed)

                VStack(spacing: 2) {
                    Text(viewModel.intensity.icon).font(.title2)
                    Text(String(format: "%.1f", viewModel.currentSpeed))
                        .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
                    Text("km/h").font(.caption).foregroundStyle(.secondary)
                }
            }

            // Intensity + distance
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text(viewModel.intensity.rawValue)
                        .font(.title3.bold()).foregroundStyle(viewModel.intensity.color)
                    Text(viewModel.intensity.speedRange)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Divider().frame(height: 30)
                VStack(spacing: 2) {
                    Text(String(format: "%.0fm", viewModel.sessionMetres))
                        .font(.title3.bold()).foregroundStyle(.purple)
                    Text("this session")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Divider().frame(height: 30)
                VStack(spacing: 2) {
                    Text(String(format: "%.0fm", viewModel.totalMetres))
                        .font(.title3.bold()).foregroundStyle(.pink)
                    Text("total").font(.caption).foregroundStyle(.secondary)
                }
            }

            // Speed slider
            VStack(spacing: 4) {
                Slider(
                    value: Binding(
                        get: { viewModel.currentSpeed },
                        set: { viewModel.setSpeed($0) }
                    ),
                    in: 0...15, step: 0.5
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
                    isCollapsed = false
                }
            } label: {
                Label("End Session", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity).padding(.vertical, 4)
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
