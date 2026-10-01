//
//  IntroView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 25/09/2026.
//
import SwiftUI
import AVKit

import Combine      // ← aggiungi questa

// MARK: - Schermata Iniziale
struct IntroView: View {
    @ObservedObject var viewModel: TripViewModel

    // Colore personalizzato #ff6a52
    let liquidColor = Color(red: 255/255, green: 106/255, blue: 82/255)

    // Le 10 frasi che ruotano sotto il titolo (ciclo infinito)
    private let rotatingLines: [String] = [
        "Tell us your budget, dates and style — we'll do the rest.",
        "Swipe through places and let your taste guide the way.",
        "Discover destinations picked just for you.",
        "From hidden gems to iconic cities, find your match.",
        "Your next adventure is just a few taps away.",
        "Smart suggestions, powered by what you love.",
        "Beaches, mountains or city lights — you choose the vibe.",
        "Build your wishlist and dream your journey.",
        "Every trip starts with a single choice.",
        "Let TripWise turn your mood into a destination."
    ]

    @State private var lineIndex = 0
    @State private var goNext = false

    // Timer che fa avanzare la frase ogni 3.5 secondi
    private let timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Video globo in loop
                LoopVideoPlayerView(videoName: "globe_video")
                    .scaleEffect(1.25)
                    .offset(y: -60)
                    .edgesIgnoringSafeArea(.all)

                // 2. Sfumatura verso il nero nella parte bassa
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.15), location: 0.0),
                        .init(color: .black.opacity(0.0), location: 0.45),
                        .init(color: .black, location: 0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    Spacer()

                    // 3. Titolo + frase che cambia gradualmente
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Every journey starts with \na choice.")
                            .font(.system(size: 38, weight: .heavy))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        // Frase rotante con dissolvenza
                        Text(rotatingLines[lineIndex])
                            .font(.body)
                            .foregroundColor(.white.opacity(0.78))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .id(lineIndex) // forza la transizione a ogni cambio
                            .transition(.opacity)
                            .frame(minHeight: 50, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .frame(height: 200, alignment: .bottom)

                    // 4. Bottone Liquid Glass
                    Button {
                        goNext = true
                    } label: {
                        Text("Start")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(liquidColor.opacity(0.65))
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.white.opacity(0.8), .white.opacity(0.1)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: liquidColor.opacity(0.5), radius: 15, x: 0, y: 10)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                    .padding(.top, 20)
                }
            }
            .navigationDestination(isPresented: $goNext) {
                TwoWayChoiceView(viewModel: viewModel)
            }
            .onReceive(timer) { _ in
                // Avanza alla frase successiva, tornando a 0 dopo l'ultima
                withAnimation(.easeInOut(duration: 0.6)) {
                    lineIndex = (lineIndex + 1) % rotatingLines.count
                }
            }
        }
    }
}

// MARK: - Componente Video Player in Loop Perfetto (Senza Scatti)
struct LoopVideoPlayerView: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    init(videoName: String) {
        super.init(frame: .zero)

        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ ERRORE: Video '\(videoName).mp4' non trovato nel progetto!")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: playerItem)
        player.isMuted = true
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non implementato")
    }
}

// MARK: - Anteprima
#Preview {
    IntroView(viewModel: TripViewModel())
}
