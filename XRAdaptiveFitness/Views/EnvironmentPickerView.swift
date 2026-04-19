import SwiftUI

struct EnvironmentPickerView: View {
    @EnvironmentObject var viewModel: FitnessSessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Environment")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(FitnessEnvironment.allCases) { env in
                    EnvironmentCard(
                        environment: env,
                        isSelected: viewModel.selectedEnvironment == env,
                        isUnlocked: viewModel.isUnlocked(env),
                        metresNeeded: viewModel.metresNeeded(for: env)
                    ) {
                        viewModel.selectEnvironment(env)
                    }
                }
            }
        }
    }
}

private struct EnvironmentCard: View {
    let environment: FitnessEnvironment
    let isSelected: Bool
    let isUnlocked: Bool
    let metresNeeded: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Text(environment.icon).font(.largeTitle)
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.black.opacity(0.55))
                            .clipShape(Circle())
                            .offset(x: 14, y: -14)
                    }
                }

                Text(environment.rawValue).font(.headline)
                Text(environment.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if !isUnlocked {
                    Text("🔒 \(Int(metresNeeded))m to unlock")
                        .font(.caption2)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.orange.opacity(0.25))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.purple.opacity(0.25) : Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.55)
    }
}
