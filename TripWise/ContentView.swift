//
//  ContentView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TripViewModel()
    
    // Variabile di stato per controllare la visibilità della splash screen
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                // Mostra la Splash Screen
                SplashScreenView()
                    .onAppear {
                        // Disattiva la splash screen dopo 2 secondi
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                // Il tuo normale flusso dell'app
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
