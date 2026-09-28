//
//  ContentView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct SlidersView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // HEADER CON IMMAGINE (ASSET)
                    ZStack(alignment: .bottomLeading) {
                        // Inserisci un'immagine nel tuo Assets chiamata "details_hero"
                        Image("details_hero")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                        
                        // Gradiente per far leggere bene il testo
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Color(UIColor.systemBackground).opacity(0.8), Color(UIColor.systemBackground)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Last details")
                                .font(.system(size: 34, weight: .heavy))
                                .foregroundColor(.primary) // Colore adattivo
                            Text("Customize your budget and preferences")
                                .font(.subheadline)
                                .foregroundColor(.secondary) // Colore adattivo
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    
                    // BLOCCHI DELLE OPZIONI
                    VStack(spacing: 20) {
                        
                        // 1. BUDGET
                        PreferenceCard(
                            title: "Budget",
                            icon: "banknote",
                            accentColor: accentColor
                        ) {
                            CustomPillSelector(
                                selectedValue: $viewModel.budgetCode,
                                options: [
                                    (label: "Low", value: 0),
                                    (label: "Medium", value: 1),
                                    (label: "High", value: 2),
                                    (label: "Luxury", value: 3)
                                ],
                                accentColor: accentColor
                            )
                        }
                        
                        // 2. RITMO DI VIAGGIO
                        PreferenceCard(
                            title: "Pace of the trip",
                            icon: "figure.walk",
                            accentColor: accentColor
                        ) {
                            CustomPillSelector(
                                selectedValue: $viewModel.activityLevelCode,
                                options: [
                                    (label: "Relax", value: 0),
                                    (label: "Balanced", value: 1),
                                    (label: "Intense", value: 2)
                                ],
                                accentColor: accentColor
                            )
                        }
                        
                        // 3. POPOLARITÀ
                        PreferenceCard(
                            title: "Destination Popularity",
                            icon: "star.fill",
                            accentColor: accentColor
                        ) {
                            CustomPillSelector(
                                selectedValue: $viewModel.popularityCode,
                                options: [
                                    (label: "Hidden", value: 0),
                                    (label: "Balanced", value: 1),
                                    (label: "Popular", value: 2)
                                ],
                                accentColor: accentColor
                            )
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30) // Spazio per non far coprire l'ultimo elemento dal bottone
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // BLOCCO INFERIORE (BOTTONE)
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        viewModel.processCoreMLRecommendation()
                    }
                }) {
                    Text("Unveil destinations!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .cornerRadius(15)
                        .shadow(color: accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                OnboardingDots(currentStep: 3, totalSteps: 4)
                    .padding(8)
                    .background(Color(UIColor.systemBackground).opacity(0.7), in: RoundedRectangle(cornerRadius: 15))
            }
            .padding(.bottom, 20)
            .padding(.top, 10)
            .background(Color(UIColor.systemBackground)) // Adattivo
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)) // Sfondo generale adattivo
    }
}

// MARK: - Componenti UI Personalizzati

// Card riutilizzabile per raggruppare le opzioni
struct PreferenceCard<Content: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    let content: Content
    
    init(title: String, icon: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary) // Adattivo
            }
            
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground)) // Adattivo (leggermente staccato dal fondo)
        .cornerRadius(18)
    }
}

// Selettore a "pillole" moderno (sostituisce il vecchio Segmented Picker)
struct CustomPillSelector: View {
    @Binding var selectedValue: Int64
    let options: [(label: String, value: Int64)]
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.value) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedValue = option.value
                    }
                }) {
                    Text(option.label)
                        .font(.subheadline)
                        .fontWeight(selectedValue == option.value ? .bold : .medium)
                        .foregroundColor(selectedValue == option.value ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedValue == option.value {
                                    accentColor
                                        .cornerRadius(10)
                                        .shadow(color: accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                                } else {
                                    Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(10)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    SlidersView(viewModel: TripViewModel())
}
