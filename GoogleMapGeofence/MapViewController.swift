import UIKit
import GoogleMaps

///Mark:- MapViewController
class MapViewController: UIViewController, GMSMapViewDelegate {
    var mapView: GMSMapView!
    var locationManager: LocationManager
    var geofenceManager: GeofenceManager
    var isDrawingEnabled: Bool

    private var liveDrawingPath: GMSMutablePath?
    private var liveDrawingPolyline: GMSPolyline?

    init(locationManager: LocationManager, geofenceManager: GeofenceManager, isDrawingEnabled: Bool) {
        self.locationManager = locationManager
        self.geofenceManager = geofenceManager
        self.isDrawingEnabled = isDrawingEnabled
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(
            withLatitude: locationManager.userLocation?.latitude ?? 18.5204,
            longitude: locationManager.userLocation?.longitude ?? 73.8567,
            zoom: 15.0
        )

        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        self.view.addSubview(mapView)

        updateUserLocationMarker()
        geofenceManager.loadGeofences(on: mapView)
        addDrawingGesture()
        updateMapGestures()
    }

    func updateMapGestures() {
        mapView.settings.scrollGestures = !isDrawingEnabled
        mapView.settings.zoomGestures = !isDrawingEnabled
        mapView.settings.rotateGestures = !isDrawingEnabled
        mapView.settings.tiltGestures = !isDrawingEnabled
    }

    //Function to update user location marker
    private func updateUserLocationMarker() {
        if let userLocation = locationManager.userLocation {
            let userMarker = GMSMarker(position: userLocation)
            userMarker.title = "You are here"
            userMarker.icon = GMSMarker.markerImage(with: .red)
            userMarker.map = mapView
        }
    }

    //Function to allow drawing gestures for geofences
    private func addDrawingGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        mapView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard isDrawingEnabled else { return }

        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.projection.coordinate(for: touchPoint)

        switch gesture.state {
        case .began:
            geofenceManager.startDrawing()
            geofenceManager.addCoordinate(coordinate)

            liveDrawingPath = GMSMutablePath()
            liveDrawingPath?.add(coordinate)
            liveDrawingPolyline = GMSPolyline(path: liveDrawingPath)
            liveDrawingPolyline?.strokeColor = .blue
            liveDrawingPolyline?.strokeWidth = 3
            liveDrawingPolyline?.map = mapView

            print("[MapViewController] Started drawing geofence at \(coordinate)")

        case .changed:
            geofenceManager.addCoordinate(coordinate)
            liveDrawingPath?.add(coordinate)
            liveDrawingPolyline?.path = liveDrawingPath

        case .ended:
            liveDrawingPolyline?.map = nil
            liveDrawingPolyline = nil
            liveDrawingPath = nil

            geofenceManager.finishDrawing(on: mapView)
            updateUserLocationMarker() // Keep user's location marker visible

            print("[MapViewController] Finished drawing geofence at \(coordinate)")

        default:
            break
        }
    }

    //Detect when a user taps on a geofence to select it
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        if let polygon = overlay as? GMSPolygon {
            geofenceManager.selectedGeofence = polygon
            print("[MapViewController] Selected Geofence \(geofenceManager.getSelectedGeofenceNumber() ?? 0)")
        }
    }
}
