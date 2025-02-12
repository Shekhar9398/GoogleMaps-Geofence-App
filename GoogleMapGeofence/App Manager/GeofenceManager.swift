import GoogleMaps
import CoreLocation

class GeofenceManager: ObservableObject {
    @Published private var geofenceCoordinates: [[CLLocationCoordinate2D]] = []
    @Published private var geofencePolygons: [GMSPolygon] = []
    @Published private var geofenceMarkers: [GMSMarker] = []
    private var geofenceNumbers: [GMSPolygon: Int] = [:] // ✅ Store geofence numbers
    @Published var selectedGeofence: GMSPolygon?

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
        polygon.fillColor = getRandomColor().withAlphaComponent(0.4) // ✅ Restored function
        polygon.strokeColor = .black
        polygon.strokeWidth = 3
        polygon.map = mapView
        polygon.isTappable = true
        geofencePolygons.append(polygon)

        let geofenceNumber = geofencePolygons.count
        geofenceNumbers[polygon] = geofenceNumber

        if let centerCoordinate = calculateGeofenceCenter(coordinates: lastGeofence) {
            let geofenceMarker = GMSMarker(position: centerCoordinate)
            geofenceMarker.title = "Geofence \(geofenceNumber)"
            geofenceMarker.icon = GMSMarker.markerImage(with: .systemMint)
            geofenceMarker.map = mapView
            geofenceMarkers.append(geofenceMarker)
        }
    }

    // ✅ Restored: Load existing geofences on the map
    func loadGeofences(on mapView: GMSMapView) {
        for polygon in geofencePolygons {
            polygon.map = mapView
        }
    }

    func getSelectedGeofenceNumber() -> Int? {
        if let selected = selectedGeofence {
            return geofenceNumbers[selected]
        }
        return nil
    }

    func clearSelectedGeofence() {
        if let selected = selectedGeofence, let index = geofencePolygons.firstIndex(of: selected) {
            selected.map = nil
            geofencePolygons.remove(at: index)

            if index < geofenceMarkers.count {
                geofenceMarkers[index].map = nil
                geofenceMarkers.remove(at: index)
            }

            geofenceCoordinates.remove(at: index)
            geofenceNumbers.removeValue(forKey: selected)
            selectedGeofence = nil
        }
    }

    // ✅ Restored: Calculate geofence center for mint marker placement
    private func calculateGeofenceCenter(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }
        let latSum = coordinates.map { $0.latitude }.reduce(0, +)
        let lngSum = coordinates.map { $0.longitude }.reduce(0, +)
        return CLLocationCoordinate2D(latitude: latSum / Double(coordinates.count),
                                      longitude: lngSum / Double(coordinates.count))
    }

    // ✅ Restored: Generate a random color for geofence fill
    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.blue, .green, .purple, .orange, .cyan, .magenta, .yellow, .red]
        return colors.randomElement() ?? .blue
    }
}
