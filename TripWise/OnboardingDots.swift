import SwiftUI

struct OnboardingDots: View {
    let currentStep: Int
    let totalSteps: Int
    private let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(0, totalSteps), id: \.self) { step in
                Circle()
                    .fill(step == currentStep ? accentColor : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentStep)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("Step \(currentStep + 1) of \(totalSteps)")
    }
}
