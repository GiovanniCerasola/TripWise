//
//  WishListView.swift
//  TripWise
//
//  Created by Samuel Antonio Mento on 22/09/2026.
//
import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - Manager per la gestione della posizione GPS
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
}

// MARK: - Vista Principale Wishlist
struct WishlistView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    @State private var viewMode: Int = 0
    
    // Istanziamo il gestore della posizione
    @StateObject private var locationManager = LocationManager()
    
    // Stato per la città selezionata sulla mappa
    @State private var selectedCity: City? = nil
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.0, longitude: 10.0),
        span: MKCoordinateSpan(latitudeDelta: 25.0, longitudeDelta: 25.0)
    ))
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View mode", selection: $viewMode) {
                    Text("List").tag(0)
                    Text("Map").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                if viewModel.wishlist.isEmpty {
                    Spacer()
                    Image(systemName: "heart.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    Text("Your wishlist is empty")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Add the destinations you like.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                } else if viewMode == 0 {
                    // --- MODALITÀ LISTA CLICCABILE ---
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            ForEach(viewModel.wishlist) { city in
                                // Ogni card della lista ora porta alla CityDetailView
                                NavigationLink(destination: CityDetailView(city: city, viewModel: viewModel)) {
                                    WishlistHorizontalCard(
                                        city: city,
                                        userLocation: locationManager.userLocation,
                                        accentColor: accentColor
                                    ) {
                                        viewModel.toggleWishlist(city: city)
                                    }
                                }
                                .buttonStyle(.plain) // Evita l'effetto di colorazione blu di default del link
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                } else {
                    // --- MODALITÀ MAPPA INTERATTIVA ---
                    ZStack(alignment: .bottom) {
                        Map(position: $cameraPosition) {
                            UserAnnotation()
                            
                            ForEach(viewModel.wishlist) { city in
                                Annotation(city.name, coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)) {
                                    Button(action: {
                                        selectedCity = city
                                    }) {
                                        VStack(spacing: 2) {
                                            Image(systemName: "mappin.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(.black)
                                                .background(Circle().fill(Color(UIColor.systemBackground)))
                                                .shadow(radius: 4)
                                            
                                            Text(city.name)
                                                .font(.caption2)
                                                .bold()
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color(UIColor.systemBackground).opacity(0.85))
                                                .cornerRadius(6)
                                                .shadow(radius: 2)
                                        }
                                    }
                                }
                            }
                        }
                        .edgesIgnoringSafeArea(.bottom)
                        
                        // POPUP IN BASSO CLICCABILE PER APRIRE I DETTAGLI DELLA CITTÀ
                        if let city = selectedCity {
                            NavigationLink(destination: CityDetailView(city: city, viewModel: viewModel)) {
                                MapDetailCard(
                                    city: city,
                                    userLocation: locationManager.userLocation,
                                    accentColor: accentColor
                                ) {
                                    selectedCity = nil
                                }
                            }
                            .buttonStyle(.plain)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.spring(), value: selectedCity)
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Wishlist")
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(accentColor)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        }
    }
}

// MARK: - Card Dettaglio sulla Mappa (Ora integrata come link)
struct MapDetailCard: View {
    let city: City
    let userLocation: CLLocationCoordinate2D?
    let accentColor: Color
    var onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(city.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let distanceText = calculateDistance() {
                    Label(distanceText, systemImage: "location.fill")
                        .font(.caption)
                        .bold()
                        .foregroundColor(accentColor)
                        .padding(.top, 2)
                } else {
                    Label("Locating you...", systemImage: "location.slash.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Freccina per indicare che è cliccabile
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.trailing, 5)
        }
        .padding(14)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private func calculateDistance() -> String? {
        guard let userLoc = userLocation else { return nil }
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let cityCLLocation = CLLocation(latitude: city.latitude, longitude: city.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: cityCLLocation)
        let distanceInKm = distanceInMeters / 1000.0
        
        if distanceInKm < 1 {
            return "Less than 1 km away"
        } else {
            return String(format: "%.0f km away", distanceInKm)
        }
    }
}

// MARK: - La carta orizzontale in modalità Lista
struct WishlistHorizontalCard: View {
    let city: City
    let userLocation: CLLocationCoordinate2D?
    let accentColor: Color
    var removeAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(city.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(city.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(city.country)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    if let distanceText = calculateDistance() {
                        Label(distanceText, systemImage: "location.fill")
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(accentColor.opacity(0.2))
                            .foregroundColor(accentColor)
                            .clipShape(Capsule())
                    }
                    
                    Text("To visit!")
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(accentColor.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Bottone cuore isolato per evitare conflitti con il tap sulla card intera
            Button(action: removeAction) {
                VStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(accentColor)
                        .font(.title3)
                    Spacer()
                }
                .padding(.top, 5)
            }
            .buttonStyle(.plain) // Assicura che il tap sul cuore non apra i dettagli della città
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func calculateDistance() -> String? {
        guard let userLoc = userLocation else { return nil }
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let cityCLLocation = CLLocation(latitude: city.latitude, longitude: city.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: cityCLLocation)
        let distanceInKm = distanceInMeters / 1000.0
        
        if distanceInKm < 1 {
            return "Less than 1 km"
        } else {
            return String(format: "%.0f km away", distanceInKm)
        }
    }
}

#Preview {
    WishlistView(viewModel: TripViewModel())
}
