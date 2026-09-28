//
//  ProfileView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. HEADER (Icona + Archetipo dinamico)
                    HStack(spacing: 15) {
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 50))
                            .foregroundColor(accentColor)
                            .background(Color.primary.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(getArchetypeTitle())
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                            Text("Your Archetype")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 2. I TUOI GUSTI (Radar Chart dinamico basato sul ViewModel)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your TripWisdom Spectrum")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        RadarChart(
                            data: computeUserPreferencesData(),
                            accentColor: accentColor
                        )
                        .frame(height: 250)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 15)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)
                    
                    // 3. TASTO AFFINA
                    Button(action: {
                        viewModel.hasFinishedOnboarding = false
                    }) {
                        Text("Choose a new destination!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .cornerRadius(15)
                            .shadow(color: accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                }
                .padding(.bottom, 35)
            }
            .navigationTitle("Your profile")
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
    
    // Calcola i 6 valori del grafico (0.0 - 1.0) in base alle esperienze e ai gusti salvati nel ViewModel
    private func computeUserPreferencesData() -> [Double] {
        let exp = viewModel.selectedExperiences
        let sceneries = viewModel.selectedSceneries
        
        // Asse 0: Relax (Spiaggia, Natura, Budget lusso/medio)
        var relaxScore = 0.3
        if exp.contains("Spiaggia") { relaxScore += 0.4 }
        if exp.contains("Natura") { relaxScore += 0.3 }
        if sceneries.contains("Mare") || sceneries.contains("Lago") { relaxScore += 0.2 }
        
        // Asse 1: Cultura (Cultura, Storia)
        var cultureScore = 0.3
        if exp.contains("Cultura") { cultureScore += 0.4 }
        if exp.contains("History") || exp.contains("Storia") { cultureScore += 0.4 }
        if sceneries.contains("Città") { cultureScore += 0.2 }
        
        // Asse 2: Natura (Natura, Montagna, Campagna)
        var natureScore = 0.3
        if exp.contains("Natura") { natureScore += 0.4 }
        if sceneries.contains("Montagna") || sceneries.contains("Campagna") || sceneries.contains("Deserto") { natureScore += 0.4 }
        
        // Asse 3: Cibo (Cibo)
        var foodScore = 0.3
        if exp.contains("Cibo") || exp.contains("Gastronomia") { foodScore += 0.6 }
        
        // Asse 4: Vita notturna (Vita Notturna)
        var nightlifeScore = 0.2
        if exp.contains("Vita Notturna") { nightlifeScore += 0.7 }
        
        // Asse 5: Avventura (Avventura, Ritmo intenso)
        var adventureScore = 0.3
        if exp.contains("Avventura") { adventureScore += 0.4 }
        if viewModel.activityLevelCode == 2 { adventureScore += 0.3 }
        if sceneries.contains("Montagna") { adventureScore += 0.2 }
        
        // Normalizziamo i valori per assicurarci che siano tra 0.1 e 1.0 per un bel disegno geometrico
        return [
            min(max(relaxScore, 0.2), 1.0),
            min(max(cultureScore, 0.2), 1.0),
            min(max(natureScore, 0.2), 1.0),
            min(max(foodScore, 0.2), 1.0),
            min(max(nightlifeScore, 0.2), 1.0),
            min(max(adventureScore, 0.2), 1.0)
        ]
    }
    
    // Restituisce un titolo dinamico per l'archetipo in base alle scelte
    private func getArchetypeTitle() -> String {
        if viewModel.selectedExperiences.contains("Avventura") { return "Adrenaline Addict" }
        if viewModel.selectedExperiences.contains("Cultura") || viewModel.selectedExperiences.contains("Storia") { return "Culture Enthusiast" }
        if viewModel.selectedExperiences.contains("Spiaggia") { return "Relaxer" }
        if viewModel.selectedSceneries.contains("Città") { return "Urban Explorer" }
        return "Generalist"
    }
    
    
    // MARK: - RADAR CHART (GRAFICO CUSTOM ADATTIVO)
    struct RadarChart: View {
        var data: [Double] // Array di 6 valori tra 0.0 e 1.0
        let labels = ["Relax", "Culture", "Nature", "Food", "Nightlife", "Adventure"]
        let accentColor: Color
        
        var body: some View {
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2 - 25
                
                ZStack {
                    // 1. Griglia (3 esagoni concentrici)
                    ForEach(1...3, id: \.self) { step in
                        PolygonShape(sides: 6, scale: CGFloat(step) / 3.0)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    }
                    
                    // 2. Assi dal centro ai vertici
                    ForEach(0..<6, id: \.self) { i in
                        Path { path in
                            path.move(to: center)
                            let angle = CGFloat(i) * (2.0 * .pi / 6.0) - .pi / 2.0
                            let x = center.x + radius * cos(angle)
                            let y = center.y + radius * sin(angle)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    }
                    
                    // 3. Area colorata basata sui dati reali dell'utente
                    DataPolygonShape(data: data)
                        .fill(accentColor.opacity(0.4))
                    
                    DataPolygonShape(data: data)
                        .stroke(accentColor, lineWidth: 2)
                    
                    // 4. Etichette di testo sui vertici
                    ForEach(0..<6, id: \.self) { i in
                        let angle = CGFloat(i) * (2.0 * .pi / 6.0) - .pi / 2.0
                        let labelRadius = radius + 22
                        let x = center.x + labelRadius * cos(angle)
                        let y = center.y + labelRadius * sin(angle)
                        
                        Text(labels[i])
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
    
    // Forma esagonale di sfondo
    struct PolygonShape: Shape {
        var sides: Int
        var scale: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let radius = (min(rect.width, rect.height) / 2 - 25) * scale
            
            for i in 0..<sides {
                let angle = CGFloat(i) * (2.0 * .pi / CGFloat(sides)) - .pi / 2.0
                let x = center.x + radius * cos(angle)
                let y = center.y + radius * sin(angle)
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            path.closeSubpath()
            return path
        }
    }
    
    // Forma dinamica basata sui dati dell'utente
    struct DataPolygonShape: Shape {
        var data: [Double]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let radius = min(rect.width, rect.height) / 2 - 25
            
            for (i, value) in data.enumerated() {
                let angle = CGFloat(i) * (2.0 * .pi / CGFloat(data.count)) - .pi / 2.0
                let normalizedValue = CGFloat(max(0, min(value, 1.0)))
                let x = center.x + radius * normalizedValue * cos(angle)
                let y = center.y + radius * normalizedValue * sin(angle)
                
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            path.closeSubpath()
            return path
        }
    }
}
    #Preview {
        ProfileView(viewModel: TripViewModel())
    }

