//
//  MainTabView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    var body: some View {
        TabView {
            
            // 1. Destinazioni consigliate
            MatchesView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "globe.europe.africa.fill")
                    Text("Destinations")
                }
            
            // 2. Wishlist
            WishlistView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Wishlist")
                }
            
            // 3. Profilo viaggiatore
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
