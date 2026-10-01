import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TripViewModel()

    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                Group {
                    if viewModel.hasFinishedOnboarding {
                        MainTabView(viewModel: viewModel)
                    } else if viewModel.hasStartedOnboarding {
                        NavigationStack {
                            TwoWayChoiceView(viewModel: viewModel)
                        }

                    } else {
                        IntroView(viewModel: viewModel)

                    }
                }
            }
        }
    }
}
