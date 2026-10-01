import SwiftUI

struct SplashScreenView: View {
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                logo
                    .accessibilityHidden(true)

                Text("TripWise")
                    .font(.system(size: 55, weight: .heavy))
                    .foregroundColor(accentColor)
                Text("Every journey starts with a choice")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
            }
        }
    }

    @ViewBuilder
    private var logo: some View {
        if UIImage(named: "icon_pic") != nil {
            Image("icon_pic")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        } else {
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
