import Foundation
import SwiftUI
import Combine
import CoreML

class TripViewModel: ObservableObject {

    private let numberOfRecommendations = 200

    @Published var seasonCode: Int64 = -1
    @Published var selectedSceneries: Set<String> = []
    @Published var selectedExperiences: Set<String> = []
    @Published var budgetCode: Int64 = 1
    @Published var activityLevelCode: Int64 = 1
    @Published var popularityCode: Int64 = 1

    @Published var hasStartedOnboarding: Bool = false

    @Published var hasFinishedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasFinishedOnboarding, forKey: "hasFinishedOnboarding")
        }
    }

    @Published var recommendedCities: [ScoredCity] = [] {
        didSet {
            saveRecommendations()
        }
    }

    @Published var wishlist: [City] = [] {
        didSet {
            var seen = Set<String>()
            let uniqueWishlist = wishlist.filter { seen.insert($0.name).inserted }

            if uniqueWishlist.count != wishlist.count {
                wishlist = uniqueWishlist
            } else {
                saveWishlist()
            }
        }
    }

    @Published var visitedCityNames: Set<String> = [] {
        didSet {
            saveVisitedCities()
        }
    }

    var visibleRecommendations: [ScoredCity] {
        recommendedCities.filter { !visitedCityNames.contains($0.city.name) }
    }

    init() {
        self.hasFinishedOnboarding = UserDefaults.standard.bool(forKey: "hasFinishedOnboarding")

        loadRecommendations()
        loadWishlist()
        loadVisitedCities()
    }

    func processCoreMLRecommendation() {
        print(" FUNZIONE CHIAMATA")
        do {
            let model = try TripWiseML(configuration: MLModelConfiguration())
            print(" MODELLO CARICATO CORRETTAMENTE")

            let experienceCode = encodeExperience()
            let sceneryCode = encodeScenery()

            var scored: [ScoredCity] = []

            for (destinationId, city) in europeanCitiesData {
                let input = TripWiseMLInput(
                    destination_id: destinationId,
                    form_a_scalar: 1,
                    form_b_scalar: budgetCode,
                    form_c_scalar: seasonCode,
                    form_f_scalar: experienceCode,
                    form_g_scalar: sceneryCode,
                    form_h_scalar: activityLevelCode,
                    form_i_scalar: 1,
                    form_j_scalar: popularityCode,
                    form_r_scalar: 0
                )

                let prediction = try model.prediction(input: input)

                let score = prediction.ratingProbability[1] ?? 0.0
                scored.append(ScoredCity(city: city, score: score))

                print("🏙️ \(city.name) [id \(destinationId)] → rating: \(prediction.rating) | prob: \(prediction.ratingProbability)")
            }

            let topScored = scored
                .sorted { $0.score > $1.score }
                .prefix(numberOfRecommendations)

            print("\n✅ TOP \(numberOfRecommendations) RACCOMANDAZIONI:")
            for (i, item) in topScored.enumerated() {
                print("   \(i + 1). \(item.city.name) — affinità \(item.matchPercentage)%")
            }
            print("")

            self.recommendedCities = Array(topScored)

        } catch {
            print("❌ ERRORE CoreML: \(error) — uso selezione casuale come fallback")
            self.recommendedCities = europeanCitiesData.values
                .shuffled()
                .prefix(numberOfRecommendations)
                .map { ScoredCity(city: $0, score: 0.0) }
        }

        self.hasFinishedOnboarding = true
    }

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
        for exp in selectedExperiences {
            if let code = map[exp] { return code }
        }
        return 2
    }

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
        return 0
    }

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
        self.wishlist.removeAll()

        UserDefaults.standard.removeObject(forKey: "savedRecommendations")
        UserDefaults.standard.removeObject(forKey: "savedWishlist")
        UserDefaults.standard.set(false, forKey: "hasFinishedOnboarding")
    }

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

    func addToWishlist(city: City) {
        guard !isInWishlist(city: city) else { return }
        wishlist.append(city)
    }

    func removeFromWishlist(city: City) {
        wishlist.removeAll(where: { $0.name == city.name })
    }

    func toggleWishlist(city: City) {
        if isInWishlist(city: city) {
            removeFromWishlist(city: city)
        } else {
            addToWishlist(city: city)
        }
    }

    func isInWishlist(city: City) -> Bool {
        return wishlist.contains(where: { $0.name == city.name })
    }

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
