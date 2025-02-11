import SwiftUI
import GoogleMaps
import CoreLocation

// MARK: - LocationManager.swift - Tracks User Location
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    ///Mark:- Closure(for Capture)to notify about location updates
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    ///Mark:- Update location on UI
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate                
                self.onLocationUpdate?(location.coordinate)
            }
        }
    }
}
