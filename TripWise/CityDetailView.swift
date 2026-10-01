import SwiftUI

struct CityDetailView: View {
    let city: City
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                ZStack(alignment: .bottomTrailing) {
                    GeometryReader { geometry in
                        Image(city.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 350)
                            .clipped()
                    }
                    .frame(height: 350)

                    LinearGradient(
                        gradient: Gradient(colors: [.clear, Color(UIColor.systemBackground)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 350)

                    Button(action: {
                        viewModel.toggleWishlist(city: city)
                    }) {
                        Image(systemName: viewModel.isInWishlist(city: city) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(viewModel.isInWishlist(city: city) ? accentColor : .primary)
                            .padding(14)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                    .offset(y: 20)
                }
                .zIndex(1)

                VStack(alignment: .leading, spacing: 15) {

                    VStack(alignment: .leading, spacing: 4) {
                        Text(city.name)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(accentColor)
                            Text(city.country)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()
                        .padding(.vertical, 5)

                    Text("Why should you visit?")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(city.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)

                    Divider()
                        .padding(.vertical, 5)

                    Toggle(isOn: Binding(
                        get: { viewModel.isVisited(city: city) },
                        set: { newValue in
                            withAnimation { viewModel.setVisited(city: city, newValue) }
                        }
                    )) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(accentColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Already visited")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("It won't appear in your destinations")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(accentColor)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(15)

                }
                .padding(20)
                .background(Color(UIColor.systemBackground))
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .tint(accentColor)
    }
}

#Preview {
    NavigationStack {
        CityDetailView(
            city: City(name: "Roma", country: "Italia", imageName: "rome_pic", latitude: 41.9, longitude: 12.5, description: "La Città Eterna, un museo a cielo aperto tra storia millenaria e dolce vita.", sceneryBitmask: 1),
            viewModel: TripViewModel()
        )
    }
}
