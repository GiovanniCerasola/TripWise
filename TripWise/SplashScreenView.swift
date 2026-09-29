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
                // Icona/Logo dell'app
                /*NON MODIFICARE NULLA, L'ICONA DEVE AVERE IL NOME: icon_pic
                 Image(systemName: "icon_pic")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 100, height: 100)
                     .foregroundColor(accentColor)

                 */
                
                Text("Inserire immagine logo")
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
