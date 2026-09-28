//
//  ContentView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI
import Combine

struct SeasonItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let subtitle: String
    let imageName: String
    let code: Int64

}

struct TwoWayChoiceView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    private let seasons: [SeasonItem] = [
        SeasonItem(title: "Winter", icon: "snowflake", subtitle: "Cold · Snow · Ambience", imageName: "winter_pic", code: 0),
        SeasonItem(title: "Spring", icon: "leaf.fill", subtitle: "Bloom · Mild · Green", imageName: "spring_pic", code: 1),
        SeasonItem(title: "Summer", icon: "sun.max.fill", subtitle: "Sun · Hot · Sea", imageName: "summer_pic", code: 2),
        SeasonItem(title: "Autumn", icon: "wind", subtitle: "Foliage · Colorful · Relax", imageName: "autumn_pic", code: 3)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                
                // Intestazione
                VStack(alignment: .leading, spacing: 5) {
                    Text("Choose the season")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Pick the season you would like to be travelling in")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                // Lista delle card isolate per evitare refresh indesiderati della view principale
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(seasons) { season in
                            SeasonCardRow(
                                season: season,
                                isSelected: viewModel.seasonCode == season.code,
                                accentColor: accentColor
                            ) {
                                // Aggiornamento di stato diretto, senza animazioni globali che fanno sfarfallare la UI
                                viewModel.seasonCode = season.code
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 140)
                }
            }
            
            // Blocco inferiore con il tasto Continua
            VStack(spacing: 12) {
                
                if viewModel.seasonCode >= 0 && viewModel.seasonCode <= 3 {
                    
                    NavigationLink(destination: EnvironmentChoiceView(viewModel: viewModel)) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                }
                
                OnboardingDots(currentStep: 0, totalSteps: 4)
                    .padding(8)
                    .background(Color.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 15))
            }
            .padding(.bottom, 20)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.95), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Sotto-vista isolata per singola card (Elimina il refresh globale della schermata)
struct SeasonCardRow: View {
    let season: SeasonItem
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                Image(season.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.92)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                
                // Contenuto testuale
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: season.icon)
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(season.title)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                        }
                        
                        Text(season.subtitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(accentColor)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? accentColor : Color.white.opacity(0.1), lineWidth: isSelected ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    NavigationStack {
        TwoWayChoiceView(viewModel: TripViewModel())
    }
}
