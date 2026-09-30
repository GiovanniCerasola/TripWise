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
                // Logo dell'app: l'asset DEVE chiamarsi "icon_pic".
                // Finché l'asset non esiste, viene mostrato un logo provvisorio.
                logo
                    .accessibilityHidden(true) // decorativo: il nome dell'app è già letto sotto
                
                // Nome dell'app
                Text("TripWise")
                    .font(.system(size: 55, weight: .heavy))
                    .foregroundColor(accentColor) // stesso arancione del resto dell'app
                Text("Every journey starts with a choice")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor) // stesso arancione del resto dell'app
            }
        }
    }
    
    // MARK: - Logo (vero o provvisorio)
    @ViewBuilder
    private var logo: some View {
        if UIImage(named: "icon_pic") != nil {
            // Logo definitivo, appena viene aggiunto agli Assets
            Image("icon_pic")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        } else {
            // Logo PROVVISORIO: aeroplano su sfondo arancione arrotondato
            RoundedRectangle(cornerRadius: 22)
                .fill(accentColor)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "airplane")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-45))
                )
                .shadow(color: accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    SplashScreenView()
}
