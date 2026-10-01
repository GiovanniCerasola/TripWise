import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    @State private var visibleCount: Int = 6

    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Text("Ranked by affinity")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(accentColor)
                    Spacer()
                    Text("\(viewModel.visibleRecommendations.count) destinations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.visibleRecommendations.prefix(visibleCount)) { scored in

                            let matchScore = scored.matchPercentage

                            NavigationLink(value: scored.city) {
                                MatchCardView(
                                    city: scored.city,
                                    matchPercentage: matchScore,
                                    accentColor: accentColor,
                                    isSaved: viewModel.isInWishlist(city: scored.city),
                                    toggleAction: { viewModel.toggleWishlist(city: scored.city) }
                                )
                            }
                            .buttonStyle(.plain)

                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    if visibleCount < viewModel.visibleRecommendations.count {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                visibleCount += 6
                            }
                        }) {
                            Text("Load more results")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .underline()
                                .foregroundColor(accentColor)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Destinations")
            .navigationDestination(for: City.self) { city in
                CityDetailView(city: city, viewModel: viewModel)
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

struct MatchCardView: View {
    let city: City
    let matchPercentage: Int
    let accentColor: Color
    let isSaved: Bool
    let toggleAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .top) {
                Image(city.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()

                HStack {
                    Text("\(matchPercentage)%")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())

                    Spacer()

                    Button(action: toggleAction) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(isSaved ? accentColor : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(city.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(city.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                    .lineLimit(2)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MatchesView(viewModel: TripViewModel())
}

extension City: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
