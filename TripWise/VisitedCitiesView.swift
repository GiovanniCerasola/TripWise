//
//  VisitedCitiesView.swift
//  TripWise
//
//  Schermata raggiungibile dal Profilo: mostra le città già visitate,
//  permette di rimuoverle (swipe) e di aggiungerne di nuove con la ricerca.
//
import SwiftUI

struct VisitedCitiesView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    @State private var searchText: String = ""
    
    // Tutte le città del catalogo, in ordine alfabetico
    private var allCities: [City] {
        europeanCitiesData.values.sorted { $0.name < $1.name }
    }
    
    // Solo quelle già visitate
    private var visitedCities: [City] {
        allCities.filter { viewModel.isVisited(city: $0) }
    }
    
    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }
    
    // Risultati della ricerca per nome città o paese
    private var searchResults: [City] {
        allCities.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.country.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }
    
    var body: some View {
        List {
            if !trimmedQuery.isEmpty {
                // --- MODALITÀ RICERCA: tocco = aggiungi/togli dalle visitate ---
                if searchResults.isEmpty {
                    ContentUnavailableView.search(text: trimmedQuery)
                        .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(searchResults, id: \.name) { city in
                            Button {
                                withAnimation { viewModel.toggleVisited(city: city) }
                            } label: {
                                VisitedCityRow(
                                    city: city,
                                    isVisited: viewModel.isVisited(city: city),
                                    accentColor: accentColor
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Tap a city to add or remove it")
                    }
                }
                
            } else if visitedCities.isEmpty {
                // --- NESSUNA CITTÀ VISITATA ---
                ContentUnavailableView(
                    "No visited cities yet",
                    systemImage: "map",
                    description: Text("Search for a city above to mark it as visited.")
                )
                .listRowBackground(Color.clear)
                
            } else {
                // --- ELENCO DELLE CITTÀ VISITATE ---
                Section {
                    ForEach(visitedCities, id: \.name) { city in
                        VisitedCityRow(city: city, isVisited: true, accentColor: accentColor)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation { viewModel.setVisited(city: city, false) }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(visitedCities.count == 1 ? "1 city visited" : "\(visitedCities.count) cities visited")
                } footer: {
                    Text("Swipe left to remove a city. Visited cities are hidden from Destinations.")
                }
            }
        }
        .navigationTitle("Visited cities")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search a city or country"
        )
        .tint(accentColor)
    }
}

// MARK: - Riga della lista
struct VisitedCityRow: View {
    let city: City
    let isVisited: Bool
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(city.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isVisited ? "checkmark.circle.fill" : "plus.circle")
                .font(.title2)
                .foregroundColor(isVisited ? accentColor : .secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // tutta la riga è toccabile
        .accessibilityElement(children: .combine)
        .accessibilityValue(isVisited ? "Visited" : "Not visited")
    }
}

#Preview {
    NavigationStack {
        VisitedCitiesView(viewModel: TripViewModel())
    }
}
