import GoogleMaps
import SwiftUI

// MARK: - GeofenceManager.swift - Handles geofence logic
class GeofenceManager: ObservableObject {
    private var paths: [GMSMutablePath] = []
    private var polygons: [GMSPolygon] = []
    private let colors: [UIColor] = [.red, .blue, .green, .yellow, .purple]

    func startDrawing() {
        paths.append(GMSMutablePath())
        print("[GeofenceManager.swift] MARK: New geofence started")
    }

    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        paths.last?.add(coordinate)
        print("[GeofenceManager.swift] MARK: Added coordinate \(coordinate), total points: \(paths.last?.count() ?? 0)")
    }

    func finishDrawing(on mapView: GMSMapView) {
        guard let path = paths.last, path.count() > 2 else {
            print("[GeofenceManager.swift] MARK: Not enough points to create a geofence")
            return
        }

        let polygon = GMSPolygon(path: path)
        polygon.fillColor = colors[polygons.count % colors.count].withAlphaComponent(0.3)
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
        polygons.append(polygon)

        // Add a marker at the first coordinate for reference
        let firstCoordinate = path.coordinate(at: 0)
        let marker = GMSMarker(position: firstCoordinate)
        marker.title = "Geofence"
        marker.map = mapView

        print("[GeofenceManager.swift] MARK: Geofence created with \(path.count()) points")
    }

    func clearGeofences() {
        for polygon in polygons {
            polygon.map = nil
        }
        polygons.removeAll()
        paths.removeAll()
        print("[GeofenceManager.swift] MARK: Cleared all geofences")
    }

    func loadGeofences(on mapView: GMSMapView) {
        for (index, path) in paths.enumerated() {
            let polygon = GMSPolygon(path: path)
            polygon.fillColor = colors[index % colors.count].withAlphaComponent(0.3)
            polygon.strokeColor = .black
            polygon.strokeWidth = 2
            polygon.map = mapView
            polygons.append(polygon)
            print("[GeofenceManager.swift] MARK: Loaded geofence \(index)")
        }
    }
}
