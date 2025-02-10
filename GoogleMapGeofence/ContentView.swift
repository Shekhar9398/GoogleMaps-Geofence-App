import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        GoogleMapView(locationManager: locationManager)
            .edgesIgnoringSafeArea(.all)
    }
}
