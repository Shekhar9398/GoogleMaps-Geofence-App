import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    var mapView: GMSMapView!
    var locationManager: LocationManager
    var geofenceManager: GeofenceManager
    var isDrawingEnabled: Bool

    // Live drawing properties
    private var liveDrawingPath: GMSMutablePath?
    private var liveDrawingPolyline: GMSPolyline?

    // Live location marker
    private var liveLocationMarker: GMSMarker?

    init(locationManager: LocationManager, geofenceManager: GeofenceManager, isDrawingEnabled: Bool) {
        self.locationManager = locationManager
        self.geofenceManager = geofenceManager
        self.isDrawingEnabled = isDrawingEnabled
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let initialCoordinate = locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let camera = GMSCameraPosition.camera(withLatitude: initialCoordinate.latitude, longitude: initialCoordinate.longitude, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        self.view.addSubview(mapView)

        // Add user location marker
        if let userLocation = locationManager.userLocation {
            addUserMarker(at: userLocation)
        }

        // Load previous geofences
        geofenceManager.loadGeofences(on: mapView)

        // Setup gestures and location updates
        addDrawingGesture()
        updateMapGestures()

        // Live location updates
        locationManager.onLocationUpdate = { [weak self] newLocation in
            self?.updateUserLocationMarker(with: newLocation)
        }
    }

    func updateMapGestures() {
        mapView.settings.scrollGestures = !isDrawingEnabled
        mapView.settings.zoomGestures = !isDrawingEnabled
        mapView.settings.rotateGestures = !isDrawingEnabled
        mapView.settings.tiltGestures = !isDrawingEnabled
    }

    private func addDrawingGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        mapView.addGestureRecognizer(panGesture)
    }

    private func addUserMarker(at coordinate: CLLocationCoordinate2D) {
        let userMarker = GMSMarker(position: coordinate)
        userMarker.title = "Your Location"
        userMarker.map = mapView
    }

    private func updateUserLocationMarker(with coordinate: CLLocationCoordinate2D) {
        if liveLocationMarker == nil {
            liveLocationMarker = GMSMarker(position: coordinate)
            liveLocationMarker?.title = "Live Location"
            liveLocationMarker?.icon = GMSMarker.markerImage(with: .green)
            liveLocationMarker?.map = mapView
        } else {
            liveLocationMarker?.position = coordinate
        }
        print("[MapViewController] Live location updated: \(coordinate)")
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
            print("[MapViewController] Drawing geofence at \(coordinate)")

        case .ended:
            liveDrawingPolyline?.map = nil
            liveDrawingPolyline = nil
            liveDrawingPath = nil

            geofenceManager.finishDrawing(on: mapView)

            let geofenceCoordinates = geofenceManager.getCurrentGeofenceCoordinates()
            print("[MapViewController] The geofence is created with coordinates: \(geofenceCoordinates)")
            print("[MapViewController] Finished drawing geofence")

        default:
            break
        }
    }
}
