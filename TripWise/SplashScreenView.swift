//
//  SplashScreenView.swift
//  TripWise
//
import SwiftUI

// MARK: - Vista della Splash Screen
struct SplashScreenView: View {
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    var body: some View {
        ZStack {
            // Sfondo della splash screen
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Logo dell'app: l'asset DEVE chiamarsi "icon_pic"
                Image("icon_pic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .accessibilityHidden(true) // decorativo: il nome dell'app è già letto sotto
                
                // Nome dell'app
                Text("TripWise")
                    .font(.system(size: 55, weight: .heavy))
                    .foregroundColor(.orange)
                Text("Every journey starts with a choice")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
