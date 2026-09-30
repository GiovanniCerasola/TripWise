//
//  TripViewModel.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import Foundation
import SwiftUI
import Combine
import CoreML

class TripViewModel: ObservableObject {
    
    // Numero di destinazioni da raccomandare: cambialo qui una volta sola.
    private let numberOfRecommendations = 200
    
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
    
    // Ora conserva anche il punteggio reale del modello per ogni città (ScoredCity)
    @Published var recommendedCities: [ScoredCity] = [] {
        didSet {
            saveRecommendations()
        }
    }
    
    @Published var wishlist: [City] = [] {
        didSet {
            saveWishlist()
        }
    }
    
    // Città già visitate dall'utente (salvate per nome, che è univoco nel catalogo).
    // Non vengono mostrate nel tab Destinations.
    @Published var visitedCityNames: Set<String> = [] {
        didSet {
            saveVisitedCities()
        }
    }
    
    /// Raccomandazioni da mostrare nel tab Destinations: esclude le città già visitate.
    var visibleRecommendations: [ScoredCity] {
        recommendedCities.filter { !visitedCityNames.contains($0.city.name) }
    }

    init() {
        // Leggiamo se l'onboarding era già stato completato
        self.hasFinishedOnboarding = UserDefaults.standard.bool(forKey: "hasFinishedOnboarding")
        
        // Carichiamo le raccomandazioni salvate in precedenza
        loadRecommendations()
        loadWishlist()
        loadVisitedCities()
    }
    
    // MARK: - Motore di raccomandazione CoreML
    
    /// Interroga il modello TripWiseML per ogni città candidata e restituisce
    /// le N con la più alta probabilità di piacere all'utente (rating = 1).
    func processCoreMLRecommendation() {
        print(" FUNZIONE CHIAMATA")
        do {
            let model = try TripWiseML(configuration: MLModelConfiguration())
            print(" MODELLO CARICATO CORRETTAMENTE")
            
            // Traduciamo le scelte dell'onboarding nei codici numerici che il modello si aspetta.
            // form_f (esperienze) e form_g (paesaggi) nel dataset erano liste: qui usiamo
            // il valore rappresentativo scelto dall'utente.
            let experienceCode = encodeExperience()
            let sceneryCode = encodeScenery()
            
            var scored: [ScoredCity] = []
            
            for (destinationId, city) in europeanCitiesData {
                let input = TripWiseMLInput(
                    destination_id: destinationId,        // la chiave del dizionario È l'id del dataset
                    form_a_scalar: 1,                     // fascia d'età: 20-39 (valore fisso di default)
                    form_b_scalar: budgetCode,            // budget
                    form_c_scalar: seasonCode,            // stagione
                    form_f_scalar: experienceCode,        // esperienza principale
                    form_g_scalar: sceneryCode,           // paesaggio principale
                    form_h_scalar: activityLevelCode,     // ritmo / livello di attività
                    form_i_scalar: 1,                     // sicurezza: bilanciato (default)
                    form_j_scalar: popularityCode,        // popolarità
                    form_r_scalar: 0                      // "ovunque" (default)
                )
                
                let prediction = try model.prediction(input: input)
                
                // ratingProbability è [Int64: Double]. La probabilità della classe "1" (piace).
                let score = prediction.ratingProbability[1] ?? 0.0
                scored.append(ScoredCity(city: city, score: score))
                
                // 🔍 DEBUG: stampa l'output completo del modello per ogni città.
                print("🏙️ \(city.name) [id \(destinationId)] → rating: \(prediction.rating) | prob: \(prediction.ratingProbability)")
            }
            
            // Ordiniamo per probabilità decrescente e prendiamo le prime N
            let topScored = scored
                .sorted { $0.score > $1.score }
                .prefix(numberOfRecommendations)
            
            // 🔍 DEBUG: riepilogo finale delle città scelte, in ordine, con lo score reale
            print("\n✅ TOP \(numberOfRecommendations) RACCOMANDAZIONI:")
            for (i, item) in topScored.enumerated() {
                print("   \(i + 1). \(item.city.name) — affinità \(item.matchPercentage)%")
            }
            print("")
            
            self.recommendedCities = Array(topScored)
            
        } catch {
            // Se il modello non è disponibile, fallback su una selezione casuale (score 0)
            print("❌ ERRORE CoreML: \(error) — uso selezione casuale come fallback")
            self.recommendedCities = europeanCitiesData.values
                .shuffled()
                .prefix(numberOfRecommendations)
                .map { ScoredCity(city: $0, score: 0.0) }
        }
        
        self.hasFinishedOnboarding = true
    }
    
    // MARK: - Traduzione scelte utente → codici del modello
    
    /// Converte l'esperienza scelta nel codice form_f del dataset Stravl.
    /// 0=Beach, 1=Adventure, 2=Nature, 3=Culture, 4=Nightlife, 5=History, 6=Shopping, 7=Cuisine
    private func encodeExperience() -> Int64 {
        let map: [String: Int64] = [
            "Beach": 0,
            "Adventure": 1,
            "Nature": 2,
            "Culture": 3,
            "Nightlife": 4,
            "History": 5,
            "Shopping": 6,
            "Food": 7
        ]
        // Prendiamo la prima esperienza selezionata che troviamo nella mappa
        for exp in selectedExperiences {
            if let code = map[exp] { return code }
        }
        return 2 // default: Nature
    }
    
    /// Converte il paesaggio scelto nel codice form_g del dataset Stravl.
    /// 0=Urban, 1=Rural, 2=Sea, 3=Mountain, 4=Lake, 5=Desert, 6=Plains, 7=Jungle
    private func encodeScenery() -> Int64 {
        let map: [String: Int64] = [
            "City": 0,
            "Countryside": 1,
            "Sea": 2,
            "Mountain": 3,
            "Lake": 4,
            "Desert": 5
        ]
        for scenery in selectedSceneries {
            if let code = map[scenery] { return code }
        }
        return 0 // default: Urban
    }
    
    // MARK: - Reset
    
    /// Reset completo: azzera onboarding, scelte, raccomandazioni e wishlist.
    func resetOnboardingAndResults() {
        self.hasFinishedOnboarding = false
        self.hasStartedOnboarding = false
        self.seasonCode = -1
        self.selectedSceneries.removeAll()
        self.selectedExperiences.removeAll()
        self.budgetCode = 1
        self.activityLevelCode = 1
        self.popularityCode = 1
        self.recommendedCities.removeAll()
        // Le città visitate NON vengono azzerate: sono un dato dell'utente, non dell'onboarding.
        
        // Puliamo la memoria persistente delle raccomandazioni
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
           let decoded = try? JSONDecoder().decode([ScoredCity].self, from: data) {
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
            // Rimuove eventuali duplicati salvati in passato (confronto per nome)
            var seen = Set<String>()
            self.wishlist = decoded.filter { seen.insert($0.name).inserted }
        }
    }
    
    private func saveVisitedCities() {
        UserDefaults.standard.set(Array(visitedCityNames), forKey: "savedVisitedCities")
    }
    
    private func loadVisitedCities() {
        if let names = UserDefaults.standard.stringArray(forKey: "savedVisitedCities") {
            self.visitedCityNames = Set(names)
        }
    }
    
    // Wishlist confrontata per NOME: resta corretta anche se gli id cambiano tra un avvio e l'altro
    func toggleWishlist(city: City) {
        if let index = wishlist.firstIndex(where: { $0.name == city.name }) {
            wishlist.remove(at: index)
        } else {
            wishlist.append(city)
        }
    }
    
    func isInWishlist(city: City) -> Bool {
        return wishlist.contains(where: { $0.name == city.name })
    }
    
    // MARK: - Città già visitate
    
    func isVisited(city: City) -> Bool {
        visitedCityNames.contains(city.name)
    }
    
    func setVisited(city: City, _ visited: Bool) {
        if visited {
            visitedCityNames.insert(city.name)
        } else {
            visitedCityNames.remove(city.name)
        }
    }
    
    func toggleVisited(city: City) {
        setVisited(city: city, !isVisited(city: city))
    }
}
