import SwiftUI

struct EnvironmentChoiceView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    @Environment(\.dismiss) var dismiss

    @State private var showMaxSelectionError: Bool = false

    let environments = [
        ("City", "urban_pic"),
        ("Countryside", "rural_pic"),
        ("Sea", "sea_pic"),
        ("Mountain", "mountain_pic"),
        ("Lake", "lake_pic"),
        ("Desert", "desert_pic")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("What sceneries are you attracted to?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Text("3 MAX")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 5)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(environments, id: \.0) { env in
                            SceneryGridCell(
                                title: env.0,
                                imageName: env.1,
                                isSelected: viewModel.selectedSceneries.contains(env.0),
                                accentColor: accentColor
                            ) {
                                if viewModel.selectedSceneries.contains(env.0) {
                                    viewModel.selectedSceneries.remove(env.0)
                                } else {
                                    if viewModel.selectedSceneries.count < 3 {
                                        viewModel.selectedSceneries.insert(env.0)
                                    } else {
                                        withAnimation(.spring()) {
                                            showMaxSelectionError = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.spring()) {
                                                showMaxSelectionError = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }

                Spacer()

                VStack(spacing: 12) {
                    NavigationLink(destination: SwipeView(viewModel: viewModel)) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(viewModel.selectedSceneries.isEmpty ? .secondary : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedSceneries.isEmpty ? Color(UIColor.systemGray5) : accentColor)
                            .cornerRadius(15)
                    }
                    .disabled(viewModel.selectedSceneries.isEmpty)
                    .padding(.horizontal)

                    OnboardingDots(currentStep: 1, totalSteps: 4)
                        .padding(8)
                        .background(Color(UIColor.systemBackground).opacity(0.7), in: RoundedRectangle(cornerRadius: 15))
                }
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))

            if showMaxSelectionError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.white)
                    Text("Choose a maximum of 3 images!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Capsule().fill(Color.red.opacity(0.9)))
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                .padding(.top, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
    }
}

struct SceneryGridCell: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let accentColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()

                LinearGradient(gradient: Gradient(colors: [.clear, Color.black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)

                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
                    .multilineTextAlignment(.center)

                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(accentColor)
                                .background(Circle().fill(Color.white))
                                .padding(10)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? accentColor : Color.primary.opacity(0.2), lineWidth: isSelected ? 4 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        EnvironmentChoiceView(viewModel: TripViewModel())
    }
}
