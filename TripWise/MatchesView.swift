//
//  MatchesView.swift
//  TripWise
//

import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    // Variabile di stato per controllare quanti risultati mostrare
    @State private var visibleCount: Int = 6
    
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
                    Text("\(viewModel.visibleRecommendations.count) destinations")
                        .font(.caption)
                        .foregroundColor(.secondary) // Adattivo
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // Lista grigliata responsive ordinata
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        // Iteriamo solo sui primi 'visibleCount' elementi
                        // Mostriamo solo le città NON ancora visitate
                        ForEach(viewModel.visibleRecommendations.prefix(visibleCount)) { scored in
                            
                            // Percentuale REALE calcolata dal modello
                            let matchScore = scored.matchPercentage
                            
                            // NavigationLink basato sul valore: se la città viene segnata come visitata
                            // e sparisce dalla lista, la schermata di dettaglio resta aperta.
                            NavigationLink(value: scored.city) {
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
                    
                    // Link testuale "Load more results": piccolo e sottolineato
                    if visibleCount < viewModel.visibleRecommendations.count {
                        Button(action: {
                            // Aggiunge altri 6 risultati con un'animazione fluida
                            withAnimation(.easeInOut) {
                                visibleCount += 6
                            }
                        }) {
                            Text("Load more results")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .underline()
                                .foregroundColor(accentColor)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Destinations")
            .navigationDestination(for: City.self) { city in
                CityDetailView(city: city, viewModel: viewModel)
            }
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

// MARK: - City Hashable
// Necessario per NavigationLink(value:). L'hash usa il nome, coerente con l'uguaglianza fra città.
extension City: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
