import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    var mapView: GMSMapView!
    var locationManager: LocationManager
    var geofenceManager: GeofenceManager
    var isDrawingEnabled: Bool

    // New properties to show live drawing
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
        
        // Set the initial camera position. Use user location if available.
        let initialCoordinate = locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let camera = GMSCameraPosition.camera(withLatitude: initialCoordinate.latitude,
                                              longitude: initialCoordinate.longitude,
                                              zoom: 15.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        // Add a marker for the user's last location.
        if let userLocation = locationManager.userLocation {
            let userMarker = GMSMarker(position: userLocation)
            userMarker.title = "Your Location"
            userMarker.map = mapView
        }
        
        // Load any previously created geofences.
        geofenceManager.loadGeofences(on: mapView)
        
        addDrawingGesture()
        updateMapGestures()
    }
    
    func updateMapGestures() {
        // Disable map gestures while drawing
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
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard isDrawingEnabled else { return }
        
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.projection.coordinate(for: touchPoint)
        
        switch gesture.state {
        case .began:
            // Start a new drawing in GeofenceManager.
            geofenceManager.startDrawing()
            geofenceManager.addCoordinate(coordinate)
            
            // Create a live drawing polyline so the user sees the line being drawn.
            liveDrawingPath = GMSMutablePath()
            liveDrawingPath?.add(coordinate)
            liveDrawingPolyline = GMSPolyline(path: liveDrawingPath)
            liveDrawingPolyline?.strokeColor = .blue
            liveDrawingPolyline?.strokeWidth = 3
            liveDrawingPolyline?.map = mapView
            
            print("[MapViewController] Started drawing geofence at \(coordinate)")
            
        case .changed:
            // Continue updating the live drawing and the GeofenceManager.
            geofenceManager.addCoordinate(coordinate)
            liveDrawingPath?.add(coordinate)
            liveDrawingPolyline?.path = liveDrawingPath
            print("[MapViewController] Drawing geofence at \(coordinate)")
            
        case .ended:
            // Remove the live drawing polyline.
            liveDrawingPolyline?.map = nil
            liveDrawingPolyline = nil
            liveDrawingPath = nil
            
            // Finalize the drawing: create the filled polygon using GeofenceManager.
            geofenceManager.finishDrawing(on: mapView)
            print("[MapViewController] Finished drawing geofence")
            
        default:
            break
        }
    }
}
