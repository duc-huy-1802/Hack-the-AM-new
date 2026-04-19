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
                        isSelected: viewModel.selectedEnvironment == env
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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(environment.icon).font(.largeTitle)
                Text(environment.rawValue).font(.headline)
                Text(environment.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if !environment.isAvailable {
                    Text("Coming Soon")
                        .font(.caption2)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.secondary.opacity(0.25))
                        .clipShape(Capsule())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!environment.isAvailable)
        .opacity(environment.isAvailable ? 1.0 : 0.45)
    }
}
