//
//  ContentView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI

struct SwipeItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct SwipeView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    
    @State private var cards: [SwipeItem] = [
        SwipeItem(imageName: "beach_pic", title: "Beach", subtitle: "Sea · Sand · Relax"),
        SwipeItem(imageName: "adventure_pic", title: "Adventure", subtitle: "Action · Exploration"),
        SwipeItem(imageName: "nature_pic", title: "Nature", subtitle: "Parks · Fresh Air · Green"),
        SwipeItem(imageName: "culture_pic", title: "Culture", subtitle: "Art · Museums · Traditions"),
        SwipeItem(imageName: "nightlife_pic", title: "Nightlife", subtitle: "Pubs · Fun · Events"),
        SwipeItem(imageName: "history_pic", title: "History", subtitle: "Monuments · Archeology"),
        SwipeItem(imageName: "shopping_pic", title: "Shopping", subtitle: "Boutiques · Markets · Fashion"),
        SwipeItem(imageName: "cuisine_pic", title: "Food", subtitle: "Gastronomy · Tastings")
    ].reversed()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Do you like what you see?")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
                Text("Swipe right if it insipires you.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ZStack {
                if cards.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(accentColor)
                            .padding(.bottom, 10)
                        
                        Text("You've seen all of the pics!")
                            .foregroundColor(.secondary)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(cards) { card in
                        MockupCardView(card: card, onSwipe: { isLike in
                            handleSwipe(for: card, isLike: isLike)
                        })
                    }
                }
            }
            .frame(height: 420)
            .padding(.horizontal)
            
            if !cards.isEmpty {
                HStack(spacing: 40) {
                    Spacer()
                    
                    Button(action: {
                        if let topCard = cards.last { handleSwipe(for: topCard, isLike: false) }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .frame(width: 65, height: 65)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    }
                    
                    Button(action: {
                        if let topCard = cards.last { handleSwipe(for: topCard, isLike: true) }
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(accentColor)
                            .frame(width: 65, height: 65)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
            } else {
                Spacer().frame(height: 75)
            }
            
            Spacer()
            
            NavigationLink(destination: SlidersView(viewModel: viewModel)) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(cards.isEmpty ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(cards.isEmpty ? accentColor : Color(UIColor.systemGray5))
                    .cornerRadius(15)
            }
            .disabled(!cards.isEmpty)
            .padding(.horizontal)
            .overlay(alignment: .bottom) {
                OnboardingDots(currentStep: 2, totalSteps: 4)
                    .offset(y: 20)
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    private func handleSwipe(for card: SwipeItem, isLike: Bool) {
        if isLike {
            viewModel.selectedExperiences.insert(card.title)
        }
        withAnimation(.easeOut(duration: 0.3)) {
            cards.removeAll { $0.id == card.id }
        }
    }
}

// MARK: - COMPONENTE CARD CON TINTA DINAMICA
struct MockupCardView: View {
    let card: SwipeItem
    var onSwipe: (Bool) -> Void
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 1. Immagine di base
            Image(card.imageName)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            
            // 2. EFFETTO TINTA (VERDE O ROSSA)
            // L'opacità aumenta in base a quanto sposti la card (massimo 50%)
            if offset.width != 0 {
                Rectangle()
                    .fill(offset.width > 0 ? Color.green : Color.red)
                    .opacity(Double(min(abs(offset.width) / 200.0, 0.5)))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            
            // 3. Sfumatura nera per leggere il testo
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            
            // 4. Testi della card
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title).font(.title2).bold().foregroundColor(.white)
                Text(card.subtitle).font(.subheadline).foregroundColor(Color.white.opacity(0.8))
            }
            .padding(24)
        }
        .offset(x: offset.width, y: offset.height * 0.2)
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .gesture(
            DragGesture()
                .onChanged { gesture in offset = gesture.translation }
                .onEnded { gesture in
                    // Soglia per lo swipe impostata a 100 pt
                    if gesture.translation.width > 100 {
                        onSwipe(true)
                    } else if gesture.translation.width < -100 {
                        onSwipe(false)
                    } else {
                        // Se non supera la soglia, torna al centro mollando l'effetto colore
                        withAnimation(.spring()) { offset = .zero }
                    }
                }
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        SwipeView(viewModel: TripViewModel())
    }
}
