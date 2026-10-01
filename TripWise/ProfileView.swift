import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)

    private var archetype: Archetype {
        ArchetypeEngine.compute(
            experiences: viewModel.selectedExperiences,
            sceneries: viewModel.selectedSceneries,
            seasonCode: viewModel.seasonCode,
            budgetCode: viewModel.budgetCode,
            activityLevelCode: viewModel.activityLevelCode,
            popularityCode: viewModel.popularityCode
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {

                    VStack(alignment: .leading, spacing: 16) {

                        HStack(spacing: 15) {
                            Image(systemName: "building.2.crop.circle")
                                .font(.system(size: 50))
                                .foregroundColor(accentColor)
                                .background(Color.primary.opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(archetype.title)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primary)
                                Text("Your Archetype")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 6) {
                            Text(archetype.subtitle)
                                .font(.headline)
                                .foregroundColor(accentColor)
                            Text(archetype.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)
                    .padding(.top, 10)

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

                    NavigationLink(destination: VisitedCitiesView(viewModel: viewModel)) {
                        HStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(accentColor)
                                .frame(width: 44, height: 44)
                                .background(accentColor.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Visited cities")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(visitedSubtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(18)
                        .contentShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.hasStartedOnboarding = true
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

    private var visitedSubtitle: String {
        let count = viewModel.visitedCityNames.count
        switch count {
        case 0: return "Mark the places you've already been"
        case 1: return "1 city visited"
        default: return "\(count) cities visited"
        }
    }

    private func computeUserPreferencesData() -> [Double] {
        let exp = viewModel.selectedExperiences
        let sceneries = viewModel.selectedSceneries

        var relaxScore = 0.3
        if exp.contains("Beach") { relaxScore += 0.4 }
        if exp.contains("Nature") { relaxScore += 0.3 }
        if sceneries.contains("Sea") || sceneries.contains("Lake") { relaxScore += 0.2 }

        var cultureScore = 0.3
        if exp.contains("Culture") { cultureScore += 0.4 }
        if exp.contains("History") { cultureScore += 0.4 }
        if sceneries.contains("City") { cultureScore += 0.2 }

        var natureScore = 0.3
        if exp.contains("Nature") { natureScore += 0.4 }
        if sceneries.contains("Mountain") || sceneries.contains("Countryside") || sceneries.contains("Desert") { natureScore += 0.4 }

        var foodScore = 0.3
        if exp.contains("Food") { foodScore += 0.6 }

        var nightlifeScore = 0.2
        if exp.contains("Nightlife") { nightlifeScore += 0.7 }

        var adventureScore = 0.3
        if exp.contains("Adventure") { adventureScore += 0.4 }
        if viewModel.activityLevelCode == 2 { adventureScore += 0.3 }
        if sceneries.contains("Mountain") { adventureScore += 0.2 }

        return [
            min(max(relaxScore, 0.2), 1.0),
            min(max(cultureScore, 0.2), 1.0),
            min(max(natureScore, 0.2), 1.0),
            min(max(foodScore, 0.2), 1.0),
            min(max(nightlifeScore, 0.2), 1.0),
            min(max(adventureScore, 0.2), 1.0)
        ]
    }

    struct RadarChart: View {
        var data: [Double]
        let labels = ["Relax", "Culture", "Nature", "Food", "Nightlife", "Adventure"]
        let accentColor: Color

        var body: some View {
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2 - 25

                ZStack {
                    ForEach(1...3, id: \.self) { step in
                        PolygonShape(sides: 6, scale: CGFloat(step) / 3.0)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    }

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

                    DataPolygonShape(data: data)
                        .fill(accentColor.opacity(0.4))

                    DataPolygonShape(data: data)
                        .stroke(accentColor, lineWidth: 2)

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
