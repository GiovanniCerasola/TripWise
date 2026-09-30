//
//  IntroView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 25/09/2026.
//
import SwiftUI
import AVKit

// MARK: - Schermata Iniziale
struct IntroView: View {
    @ObservedObject var viewModel: TripViewModel
    
    // Il tuo colore personalizzato #ff6a52
    let liquidColor = Color(red: 255/255, green: 106/255, blue: 82/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                            // 1. Sfondo Video in Loop a tutto schermo
                            LoopVideoPlayerView(videoName: "globe_video")
                                .scaleEffect(1.2) // <-- AGGIUNGI QUESTO: Zooma il video del 15% per tagliare i bordi e nascondere i loghi!
                                .edgesIgnoringSafeArea(.all)
                            
                            // Overlay scuro per far risaltare il testo
                            Color.black.opacity(0.3)
                                .edgesIgnoringSafeArea(.all)
                VStack {
                    
                    Spacer()
                    
                    // 3. Bottone Liquid Glass
                    NavigationLink(destination: TwoWayChoiceView(viewModel: viewModel)) {
                        Text("Let's start")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 220, height: 65)
                            .background(
                                ZStack {
                                    // Base sfocata fusa con il tuo colore #ff6a52
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(liquidColor.opacity(0.65))
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 35))
                                    
                                    // Riflesso superiore del vetro (bordo lucido)
                                    RoundedRectangle(cornerRadius: 35)
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
                    .padding(.bottom, 60)
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
        
        // Cerca il video nel Bundle principale
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ ERRORE: Video '\(videoName).mp4' non trovato nel progetto!")
            return
        }
        
        // Setup del player a coda per il loop perfetto
        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: playerItem)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Crea il looper
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        // Fai partire il video in automatico
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
