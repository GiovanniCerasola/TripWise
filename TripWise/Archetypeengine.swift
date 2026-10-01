import Foundation

enum TravelDimension: CaseIterable {
    case culture
    case adventure
    case relax
    case nature
    case social
    case foodie
    case luxury
    case explorer
}

struct Archetype {
    let title: String
    let subtitle: String
    let description: String
}

enum ArchetypeEngine {

    static func compute(
        experiences: Set<String>,
        sceneries: Set<String>,
        seasonCode: Int64,
        budgetCode: Int64,
        activityLevelCode: Int64,
        popularityCode: Int64
    ) -> Archetype {

        var scores: [TravelDimension: Double] = [:]
        for dim in TravelDimension.allCases { scores[dim] = 0 }

        func add(_ dim: TravelDimension, _ points: Double) {
            scores[dim, default: 0] += points
        }

        if experiences.contains("Culture")   { add(.culture, 2) }
        if experiences.contains("History")   { add(.culture, 2) }
        if experiences.contains("Adventure") { add(.adventure, 2) }
        if experiences.contains("Beach")     { add(.relax, 2) }
        if experiences.contains("Nature")    { add(.nature, 2) }
        if experiences.contains("Nightlife") { add(.social, 2) }
        if experiences.contains("Food")      { add(.foodie, 3) }
        if experiences.contains("Shopping")  { add(.luxury, 1); add(.social, 1) }

        if sceneries.contains("City")        { add(.culture, 1); add(.social, 1) }
        if sceneries.contains("Mountain")    { add(.adventure, 2); add(.nature, 1) }
        if sceneries.contains("Sea")         { add(.relax, 2) }
        if sceneries.contains("Lake")        { add(.relax, 1); add(.nature, 1) }
        if sceneries.contains("Countryside") { add(.nature, 2) }
        if sceneries.contains("Desert")      { add(.explorer, 2); add(.adventure, 1) }

        if activityLevelCode == 2 { add(.adventure, 2) }
        if activityLevelCode == 0 { add(.relax, 2) }

        if budgetCode >= 2 { add(.luxury, 2) }
        if budgetCode == 0 { add(.explorer, 1) }

        if popularityCode == 0 { add(.explorer, 3) }
        if popularityCode == 2 { add(.social, 1) }

        if seasonCode == 2 { add(.relax, 1) }
        if seasonCode == 0 { add(.adventure, 1) }

        let ranked = scores.sorted { $0.value > $1.value }
        let top = ranked.first?.key ?? .culture
        let second = ranked.dropFirst().first?.key ?? .culture
        let topScore = ranked.first?.value ?? 0

        if topScore == 0 {
            return Archetype(
                    title: "Free Spirit",
                    subtitle: "Open to anything",
                    description: "You take each place as it comes, open to wherever the journey leads."
                )
        }

        return archetype(for: top, and: second)
    }

    private static func archetype(for top: TravelDimension, and second: TravelDimension) -> Archetype {
        switch top {
        case .culture:
            if second == .foodie {
                return Archetype(
                    title: "Cultural Gourmet",
                    subtitle: "Art, history and great food",
                    description: "You explore a place through its museums by day and its finest tables by night."
                )
            }
            if second == .social {
                return Archetype(
                    title: "City Sophisticate",
                    subtitle: "Museums by day, nightlife by night",
                    description: "Galleries by day, nightlife by night — you love a city that never slows down."
                )
            }
            if second == .luxury {
                return Archetype(
                    title: "Grand Tourer",
                    subtitle: "Timeless culture in style",
                    description: "You seek timeless art and architecture, always with a touch of comfort and style."
                )
            }
            return Archetype(
                    title: "Culture Enthusiast",
                    subtitle: "History, art and traditions",
                    description: "You travel to learn, drawn to history, art and local traditions."
                )

        case .adventure:
            if second == .nature {
                return Archetype(
                    title: "Wild Explorer",
                    subtitle: "Peaks, trails and the outdoors",
                    description: "You're happiest on a trail, surrounded by peaks and wild, open landscapes."
                )
            }
            if second == .explorer {
                return Archetype(
                    title: "Trailblazer",
                    subtitle: "Off-grid and off the map",
                    description: "You go where the guidebooks stop, chasing remote and untouched corners."
                )
            }
            if second == .relax {
                return Archetype(
                    title: "Active Escaper",
                    subtitle: "Adrenaline with a breather",
                    description: "You crave adventure by day and know exactly when to slow down and recharge."
                )
            }
            return Archetype(
                    title: "Adrenaline Addict",
                    subtitle: "Always chasing the next thrill",
                    description: "Sitting still isn't a holiday — you seek action and a rush wherever you go."
                )

        case .relax:
            if second == .luxury {
                return Archetype(
                    title: "Beach Connoisseur",
                    subtitle: "Sun, sea and the finer things",
                    description: "You love a beautiful shoreline paired with genuine comfort and style."
                )
            }
            if second == .nature {
                return Archetype(
                    title: "Slow Wanderer",
                    subtitle: "Quiet shores and calm days",
                    description: "You travel to unwind, favouring quiet shores and unhurried, peaceful days."
                )
            }
            if second == .social {
                return Archetype(
                    title: "Sunseeker",
                    subtitle: "Beaches, bars and good vibes",
                    description: "Sun, beaches and good company are all you need for the perfect escape."
                )
            }
            return Archetype(
                    title: "Relaxer",
                    subtitle: "Rest, recharge, repeat",
                    description: "A holiday is your time to switch off, rest and truly recharge."
                )

        case .nature:
            if second == .adventure {
                return Archetype(
                    title: "Wild Explorer",
                    subtitle: "Peaks, trails and the outdoors",
                    description: "You're happiest on a trail, surrounded by peaks and wild, open landscapes."
                )
            }
            if second == .relax {
                return Archetype(
                    title: "Nature Soul",
                    subtitle: "Lakes, forests and fresh air",
                    description: "You find peace among forests, lakes and open countryside."
                )
            }
            return Archetype(
                    title: "Naturalist",
                    subtitle: "At home in the great outdoors",
                    description: "You feel most alive outdoors, far from any city skyline."
                )

        case .social:
            if second == .culture {
                return Archetype(
                    title: "City Sophisticate",
                    subtitle: "Museums by day, nightlife by night",
                    description: "Galleries by day, nightlife by night — you love a city that never slows down."
                )
            }
            if second == .luxury {
                return Archetype(
                    title: "Jetsetter",
                    subtitle: "Trendy spots and vibrant nights",
                    description: "You're drawn to trendy spots, vibrant nights and where the scene peaks."
                )
            }
            return Archetype(
                    title: "Social Butterfly",
                    subtitle: "Where the energy is",
                    description: "You travel for the people and the energy, always in the middle of the action."
                )

        case .foodie:
            if second == .culture {
                return Archetype(
                    title: "Cultural Gourmet",
                    subtitle: "Art, history and great food",
                    description: "You explore a place through its museums by day and its finest tables by night."
                )
            }
            if second == .luxury {
                return Archetype(
                    title: "Fine Diner",
                    subtitle: "In search of the perfect table",
                    description: "You plan your trips around great restaurants and unforgettable meals."
                )
            }
            return Archetype(
                    title: "Food Explorer",
                    subtitle: "Traveling one dish at a time",
                    description: "You discover the world one dish at a time, from street food to local markets."
                )

        case .luxury:
            if second == .relax {
                return Archetype(
                    title: "Beach Connoisseur",
                    subtitle: "Sun, sea and the finer things",
                    description: "You love a beautiful shoreline paired with genuine comfort and style."
                )
            }
            if second == .culture {
                return Archetype(
                    title: "Grand Tourer",
                    subtitle: "Timeless culture in style",
                    description: "You seek timeless art and architecture, always with a touch of comfort and style."
                )
            }
            return Archetype(
                    title: "Luxury Seeker",
                    subtitle: "Only the very best",
                    description: "You believe a journey should be indulgent, with only the very best."
                )

        case .explorer:
            if second == .adventure {
                return Archetype(
                    title: "Trailblazer",
                    subtitle: "Off-grid and off the map",
                    description: "You go where the guidebooks stop, chasing remote and untouched corners."
                )
            }
            if second == .culture {
                return Archetype(
                    title: "Hidden-Gem Hunter",
                    subtitle: "Seeking places others miss",
                    description: "You skip the obvious, seeking out the treasures the crowds have missed."
                )
            }
            return Archetype(
                    title: "Off-Beat Traveler",
                    subtitle: "The road less traveled",
                    description: "You steer away from tourist hotspots toward quieter, more genuine places."
                )
        }
    }
}
