//
//  ContentView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import Foundation
import SwiftUI
import Combine

class TripViewModel: ObservableObject {
    @Published var seasonCode: Int64 = -1
    @Published var selectedSceneries: Set<String> = []
    @Published var selectedExperiences: Set<String> = []
    @Published var budgetCode: Int64 = 1
    @Published var activityLevelCode: Int64 = 1
    @Published var popularityCode: Int64 = 1
    
    @Published var hasStartedOnboarding: Bool = false
    
    // Salviamo lo stato di fine onboarding e le città raccomandate in modo persistente
    @Published var hasFinishedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasFinishedOnboarding, forKey: "hasFinishedOnboarding")
        }
    }
    
    @Published var recommendedCities: [City] = [] {
        didSet {
            saveRecommendations()
        }
    }
    
    @Published var wishlist: [City] = [] {
        didSet {
            saveWishlist()
        }
    }

    init() {
        // Leggiamo se l'onboarding era già stato completato
        self.hasFinishedOnboarding = UserDefaults.standard.bool(forKey: "hasFinishedOnboarding")
        
        // Carichiamo le raccomandazioni salvate in precedenza
        loadRecommendations()
        loadWishlist()
    }
    
    // Funzione del motore di raccomandazione
    func processCoreMLRecommendation() {
        // Qui avviene la generazione delle mete basata sul modello CoreML o sui filtri
        // Per esempio, peschiamo le città dal dataset (CityData):
        self.recommendedCities = europeanCitiesData.values.shuffled().prefix(6).map { $0 }
        self.hasFinishedOnboarding = true
    }
    
    // 🧹 FUNZIONE DI RESET COMPLETO (chiamata dal tasto nel Profilo)
    func resetOnboardingAndResults() {
        self.hasFinishedOnboarding = false
        self.hasStartedOnboarding = false
        self.seasonCode = -1
        self.selectedSceneries.removeAll()
        self.selectedExperiences.removeAll()
        self.recommendedCities.removeAll()
        
        // Puliamo anche la memoria persistente delle raccomandazioni
        UserDefaults.standard.removeObject(forKey: "savedRecommendations")
        UserDefaults.standard.set(false, forKey: "hasFinishedOnboarding")
    }
    
    // MARK: - Persistenza con UserDefaults
    private func saveRecommendations() {
        if let encoded = try? JSONEncoder().encode(recommendedCities) {
            UserDefaults.standard.set(encoded, forKey: "savedRecommendations")
        }
    }
    
    private func loadRecommendations() {
        if let data = UserDefaults.standard.data(forKey: "savedRecommendations"),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            self.recommendedCities = decoded
        }
    }
    
    private func saveWishlist() {
        if let encoded = try? JSONEncoder().encode(wishlist) {
            UserDefaults.standard.set(encoded, forKey: "savedWishlist")
        }
    }
    
    private func loadWishlist() {
        if let data = UserDefaults.standard.data(forKey: "savedWishlist"),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            self.wishlist = decoded
        }
    }
    
    func toggleWishlist(city: City) {
        if let index = wishlist.firstIndex(where: { $0.id == city.id }) {
            wishlist.remove(at: index)
        } else {
            wishlist.append(city)
        }
    }
    
    func isInWishlist(city: City) -> Bool {
        return wishlist.contains(where: { $0.id == city.id })
    }
}
