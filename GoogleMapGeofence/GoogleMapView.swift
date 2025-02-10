import SwiftUI
import GoogleMaps

///Mark:- SwiftUI doesnt support GMSMapView :. we are using UIViewRepresentable
struct GoogleMapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager

    let mapView = GMSMapView() // displaying map
    let marker = GMSMarker() // pinning the location(mark)


    ///Mark:- Create a View for SwiftUI
    func makeUIView(context: Context) -> GMSMapView {
        return mapView
    }

    ///Mark:- Update the SwiftUI View as get the UserLocation
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        if let location = locationManager.userLocation {
            marker.position = location
            marker.map = uiView
        }
    }
}
