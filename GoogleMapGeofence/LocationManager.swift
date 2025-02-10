import Foundation
import CoreLocation

///Mark: Location Manager Helps to keep track on the users current location(GPS)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request permission
        locationManager.startUpdatingLocation() // Start tracking location
    }
    
    ///Mark:- Sends Last Location of the user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                print("[LocationManager]:- Users Last Location is - \(location.coordinate)")
                self.userLocation = location.coordinate
            }
        }
    }
}
