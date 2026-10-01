import SwiftUI
import MapKit
import CoreLocation
import Combine

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

struct WishlistView: View {
    @ObservedObject var viewModel: TripViewModel
    let accentColor = Color(red: 1.0, green: 0.35, blue: 0.3)
    @State private var viewMode: Int = 0

    @StateObject private var locationManager = LocationManager()

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
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            ForEach(viewModel.wishlist) { city in
                                NavigationLink(destination: CityDetailView(city: city, viewModel: viewModel)) {
                                    WishlistHorizontalCard(
                                        city: city,
                                        userLocation: locationManager.userLocation,
                                        accentColor: accentColor
                                    ) {
                                        viewModel.toggleWishlist(city: city)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                } else {
                    ZStack(alignment: .bottom) {
                        Map(position: $cameraPosition) {

                            if let userLoc = locationManager.userLocation {
                                Annotation("You", coordinate: userLoc) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.25))
                                            .frame(width: 34, height: 34)
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 18, height: 18)
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            }

                            ForEach(viewModel.wishlist) { city in
                                Annotation(city.name, coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)) {
                                    Button(action: {
                                        selectedCity = city
                                    }) {
                                        VStack(spacing: 2) {
                                            Image(systemName: "mappin.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(accentColor)
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

            Button(action: removeAction) {
                VStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(accentColor)
                        .font(.title3)
                    Spacer()
                }
                .padding(.top, 5)
            }
            .buttonStyle(.plain)
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
