//
//  MatchesView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    // Griglia adattiva: si stringe a 1 colonna in verticale e si apre a più colonne in orizzontale
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                // Intestazione
                HStack {
                    Text("Ranked by affinity")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(accentColor)
                    Spacer()
                    Text("\(viewModel.recommendedCities.count) destinations")
                        .font(.caption)
                        .foregroundColor(.secondary) // Adattivo
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // Lista grigliata responsive ordinata
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        // Ora iteriamo direttamente sugli ScoredCity: ognuno porta il suo score reale
                        ForEach(viewModel.recommendedCities) { scored in
                            
                            // Percentuale REALE calcolata dal modello (non più 98 - index*2)
                            let matchScore = scored.matchPercentage
                            
                            // Avvolgiamo la card in un NavigationLink
                            NavigationLink(destination: CityDetailView(city: scored.city, viewModel: viewModel)) {
                                MatchCardView(
                                    city: scored.city,
                                    matchPercentage: matchScore,
                                    accentColor: accentColor,
                                    isSaved: viewModel.isInWishlist(city: scored.city),
                                    toggleAction: { viewModel.toggleWishlist(city: scored.city) }
                                )
                            }
                            .buttonStyle(.plain) // Evita che l'intera card diventi blu di default
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Destinations")
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)) // Sfondo adattivo
        }
    }
}

struct MatchCardView: View {
    let city: City
    let matchPercentage: Int
    let accentColor: Color
    let isSaved: Bool
    let toggleAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .top) {
                Image(city.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                HStack {
                    Text("\(matchPercentage)%")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        // Background semi-trasparente scuro (rimane nero per contrastare la foto)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button(action: toggleAction) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(isSaved ? accentColor : .white)
                            .padding(8)
                            // Background semi-trasparente scuro (rimane nero per contrastare la foto)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(city.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary) // Adattivo
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Adattivo
                Text(city.description)
                    .font(.footnote)
                    .foregroundColor(.secondary) // Adattivo
                    .padding(.top, 2)
                    .lineLimit(2) // Evita che descrizioni lunghe spacchino la card
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground)) // Sfondo della card adattivo
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Leggera ombra per far risaltare le card nel tema chiaro
    }
}

#Preview {
    MatchesView(viewModel: TripViewModel())
}
