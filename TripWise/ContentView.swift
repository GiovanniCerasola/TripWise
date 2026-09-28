//
//  ContentView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TripViewModel()
    
    var body: some View {
        Group {
            if viewModel.hasFinishedOnboarding {
                MainTabView(viewModel: viewModel)
            } else if viewModel.hasStartedOnboarding {
                NavigationStack {
                    TwoWayChoiceView(viewModel: viewModel)
                }
                .preferredColorScheme(.dark)
            } else {
                IntroView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
