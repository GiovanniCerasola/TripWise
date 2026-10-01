import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    var body: some View {
        TabView {

            MatchesView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "globe.europe.africa.fill")
                    Text("Destinations")
                }

            WishlistView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Wishlist")
                }

            ProfileView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .tint(accentColor)

    }
}

#Preview {
    MainTabView(viewModel: TripViewModel())
}
