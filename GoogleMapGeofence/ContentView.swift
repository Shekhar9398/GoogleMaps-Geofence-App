import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var geofenceManager = GeofenceManager()
    @State private var isDrawingEnabled = false

    var body: some View {
        ZStack {
            GoogleMapView(locationManager: locationManager,
                          geofenceManager: geofenceManager,
                          isDrawingEnabled: $isDrawingEnabled)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: {
                    isDrawingEnabled.toggle()
                    print("[ContentView.swift] Debug: Drawing mode set to \(isDrawingEnabled)")
                }) {
                    Text(isDrawingEnabled ? "Stop Drawing" : "Start Drawing")
                        .padding()
                        .background(isDrawingEnabled ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .padding()
            }
        }
    }
}
