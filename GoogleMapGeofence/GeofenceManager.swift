import GoogleMaps
import SwiftUI

class GeofenceManager: ObservableObject {
    private var geofenceCoordinates: [[CLLocationCoordinate2D]] = []

    func startDrawing() {
        geofenceCoordinates.append([])
    }

    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        geofenceCoordinates[geofenceCoordinates.count - 1].append(coordinate)
    }

    func finishDrawing(on mapView: GMSMapView) {
        guard let lastGeofence = geofenceCoordinates.last, lastGeofence.count > 2 else { return }
        
        let path = GMSMutablePath()
        for coordinate in lastGeofence {
            path.add(coordinate)
        }
        
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = getRandomColor().withAlphaComponent(0.4) // ✅ Colorful inside fill
        polygon.strokeColor = .black // ✅ Black border
        polygon.strokeWidth = 3
        polygon.map = mapView

        // ✅ Add a mint-colored marker at the geofence center
        if let centerCoordinate = calculateGeofenceCenter(coordinates: lastGeofence) {
            let geofenceMarker = GMSMarker(position: centerCoordinate)
            geofenceMarker.title = "Geofence \(geofenceCoordinates.count)"
            geofenceMarker.icon = GMSMarker.markerImage(with: .systemMint)
            geofenceMarker.map = mapView
        }
    }

    func getCurrentGeofenceCoordinates() -> [CLLocationCoordinate2D]? {
        return geofenceCoordinates.last
    }

    func loadGeofences(on mapView: GMSMapView) {
        for geofence in geofenceCoordinates {
            let path = GMSMutablePath()
            for coordinate in geofence {
                path.add(coordinate)
            }
            
            let polygon = GMSPolygon(path: path)
            polygon.fillColor = getRandomColor().withAlphaComponent(0.4) // ✅ Colorful inside
            polygon.strokeColor = .black // ✅ Black border
            polygon.strokeWidth = 3
            polygon.map = mapView
        }
    }

    // ✅ Helper function to calculate the center of the geofence
    private func calculateGeofenceCenter(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }
        
        let latSum = coordinates.map { $0.latitude }.reduce(0, +)
        let lngSum = coordinates.map { $0.longitude }.reduce(0, +)
        
        return CLLocationCoordinate2D(latitude: latSum / Double(coordinates.count),
                                      longitude: lngSum / Double(coordinates.count))
    }

    // ✅ Random color generator for colorful inside fill
    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.blue, .green, .purple, .orange, .cyan, .magenta, .yellow, .red]
        return colors.randomElement() ?? .blue
    }
}
