/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller.
*/

import UIKit
import RealityKit
import ARKit
import MapKit
import Photos
import GoogleMapsTileOverlay

struct PhotoMarker {
    var name: String
    var latitude: Double
    var longitude: Double
    var angle: Double
}

struct AudioMarker {
    var name: String
    var latitude: Double
    var longitude: Double
    var angle: Double
}

let photoMarkers  =  [
    PhotoMarker(name: "111Lawrence", latitude: 40.69270997971054, longitude: -73.98618571934942, angle: 0),
    PhotoMarker(name: "116Lawrence", latitude: 40.692798705576735, longitude: -73.9863043651857, angle: 0)
]

let audioMarkers  =  [
    PhotoMarker(name: "111Lawrence", latitude: 40.69288866484105, longitude: -73.98616621731001, angle: 0),
]

class ViewController: UIViewController, ARSessionDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toastLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var trackingStateLabel: UILabel!
    
    let coachingOverlay = ARCoachingOverlayView()
    
    let locationManager = CLLocationManager()
    
    var currentAnchors: [ARAnchor] {
        return arView.session.currentFrame?.anchors ?? []
    }
    
    var previouslyLocalized = false;
        
    // Geo anchors ordered by the time of their addition to the scene.
    var geoAnchors: [GeoAnchorWithAssociatedData] = []
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this view controller as the session's delegate.
        arView.session.delegate = self
        
        // Enable coaching.
        setupCoachingOverlay()
        
        // Set this view controller as the Core Location manager delegate.
        locationManager.delegate = self
        
        // Set this view controller as the MKMapView delegate.
        mapView.delegate = self
        
        // Generate custom overlay for MapView
        addCustomOverlay()
        
        // Disable automatic configuration and set up geo tracking
        arView.automaticallyConfigureSession = false
                
        // Run a new AR Session.
        restartSession()
                
        // Add tap gesture recognizers
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnARView(_:))))
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnMapView(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start listening for location updates from Core Location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Disable Core Location when the view disappears.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - User Interaction
    // Responds to a user tap on the AR view.
    @objc
    func handleTapOnARView(_ sender: UITapGestureRecognizer) {//        let point = sender.location(in: view)
        // Detect tap on entity
        // Extended from https://stackoverflow.com/questions/56736645/hittest-prints-ar-entity-name-even-when-i-am-not-tapping-on-it
        let tapLocation: CGPoint = sender.location(in: arView)
        let result: [CollisionCastHit] = arView.hitTest(tapLocation)
        guard let hitTest: CollisionCastHit = result.first
        else {
            showToast("Not on entity")
            return
        }
        
        let entity: Entity = hitTest.entity
        showToast("Name: \(entity.name)")
        
        // Perform ARKit raycast on tap location
//        if let result = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any).first {
//            addGeoAnchor(at: result.worldTransform.translation)
//        } else {
//            showToast("No raycast result.\nTry pointing at a different area\nor move closer to a surface.")
//        }
    }
    
    // Responds to a user tap on the map view.
    @objc
    func handleTapOnMapView(_ sender: UITapGestureRecognizer) {
        showToast("Map Tap!")
    }
    
    @IBAction func handleTapOnInfoButton(_ sender: Any) {
        showToast("Info Tap!")
    }
    
    
    // MARK: - Methods

    func restartSession() {
        // Check geo-tracking location-based availability.
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                let errorDescription = error?.localizedDescription ?? ""
                let recommendation = "Please try again in an area where geo tracking is supported."
                let restartSession = UIAlertAction(title: "Restart Session", style: .default) { (_) in
                    self.restartSession()
                }
                self.alertUser(withTitle: "Geo tracking unavailable",
                               message: "\(errorDescription)\n\(recommendation)",
                               actions: [restartSession])
            }
        }
        
        // Re-run the ARKit session.
        let geoTrackingConfig = ARGeoTrackingConfiguration()
        geoTrackingConfig.planeDetection = [.horizontal]
        arView.session.run(geoTrackingConfig)
        geoAnchors.removeAll()
        
        arView.scene.anchors.removeAll()
        
        trackingStateLabel.text = ""
        
        // Remove all anchor overlays from the map view
        let anchorOverlays = mapView.overlays.filter { $0 is AnchorIndicator }
        mapView.removeOverlays(anchorOverlays)
        
        showToast("Running new AR session")
    }
    
    func addGeoAnchor(at worldPosition: SIMD3<Float>) {
        arView.session.getGeoLocation(forPoint: worldPosition) { (location, altitude, error) in
            if let error = error {
                self.alertUser(withTitle: "Cannot add geo anchor",
                               message: "An error occurred while translating ARKit coordinates to geo coordinates: \(error.localizedDescription)")
                return
            }
            self.addGeoAnchor(at: location, altitude: altitude)
        }
    }
    
    func addGeoAnchor(at location: CLLocationCoordinate2D, altitude: CLLocationDistance? = nil) {
        var geoAnchor: ARGeoAnchor!
        if let altitude = altitude {
            geoAnchor = ARGeoAnchor(coordinate: location, altitude: altitude)
        } else {
            geoAnchor = ARGeoAnchor(coordinate: location)
        }
        
        addGeoAnchor(geoAnchor)
    }
    
    func addGeoAnchor(_ geoAnchor: ARGeoAnchor) {
        
        // Don't add a geo anchor if Core Location isn't sure yet where the user is.
        guard isGeoTrackingLocalized else {
            alertUser(withTitle: "Cannot add geo anchor", message: "Unable to add geo anchor because geo tracking has not yet localized.")
            return
        }
        arView.session.add(anchor: geoAnchor)
    }
    
    var isGeoTrackingLocalized: Bool {
        if let status = arView.session.currentFrame?.geoTrackingStatus, status.state == .localized {
            return true
        }
        return false
    }
    
    func distanceFromDevice(_ coordinate: CLLocationCoordinate2D) -> Double {
        if let devicePosition = locationManager.location?.coordinate {
            return MKMapPoint(coordinate).distance(to: MKMapPoint(devicePosition))
        } else {
            return 0
        }
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for geoAnchor in anchors.compactMap({ $0 as? ARGeoAnchor }) {
            // Effect a spatial-based delay to avoid blocking the main thread.
            DispatchQueue.main.asyncAfter(deadline: .now() + (distanceFromDevice(geoAnchor.coordinate) / 10)) {
                // Add an AR placemark visualization for the geo anchor.
                self.arView.scene.addAnchor(Entity.placemarkEntity(for: geoAnchor))
            }
            // Add a visualization for the geo anchor in the map view.
            let anchorIndicator = AnchorIndicator(center: geoAnchor.coordinate)
            self.mapView.addOverlay(anchorIndicator)

            // Remember the geo anchor we just added
            let anchorInfo = GeoAnchorWithAssociatedData(geoAnchor: geoAnchor, mapOverlay: anchorIndicator)
            self.geoAnchors.append(anchorInfo)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.restartSession()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    /// - Tag: GeoTrackingStatus
    // Called on changes in tracking status
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        var text = geoTrackingStatus.state.description

        // In localized state, show geo tracking accuracy
        if geoTrackingStatus.state == .localized {
            text += ", Accuracy: \(geoTrackingStatus.accuracy.description)"
            // If this is the first localization of the app session
            if(!previouslyLocalized){
                previouslyLocalized = true
                for marker in photoMarkers {
                    print("\(marker.latitude) : \(marker.longitude)")
                    addGeoAnchor(at: CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude))
                }
            }
        } else {
            // Otherwise show details why geo tracking couldn't localize (yet)
            switch geoTrackingStatus.stateReason {
            case .none:
                break
            case .worldTrackingUnstable:
                let arTrackingState = session.currentFrame?.camera.trackingState
                if case let .limited(arTrackingStateReason) = arTrackingState {
                    text += "\n\(geoTrackingStatus.stateReason.description): \(arTrackingStateReason.description)."
                } else {
                    fallthrough
                }
            default: text += "\n\(geoTrackingStatus.stateReason.description)."
            }
        }
        self.trackingStateLabel.text = text
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update location indicator with live estimate from Core Location
        guard let location = locations.last else { return }
        
        // Update map area
        let camera = MKMapCamera(lookingAtCenter: location.coordinate,
                                 fromDistance: CLLocationDistance(750),
                                 pitch: 0,
                                 heading: mapView.camera.heading)
        mapView.setCamera(camera, animated: false)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let anchorOverlay = overlay as? AnchorIndicator {
            let anchorOverlayView = MKCircleRenderer(circle: anchorOverlay)
            anchorOverlayView.strokeColor = .white
            anchorOverlayView.fillColor = .blue
            anchorOverlayView.lineWidth = 2
            return anchorOverlayView
        }
        
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        return MKOverlayRenderer(overlay: overlay)
//        return MKOverlayRenderer()
    }
    
    // MARK: - Utilities
    // From https://github.com/thepeaklab/GoogleMapsTileOverlay
    private func addCustomOverlay() {
        print("Adding overlay")
        guard let jsonURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") else {
            print("Could not find map style")
            return
        }

        do {
            let gmTileOverlay = try GoogleMapsTileOverlay(jsonURL: jsonURL)
            gmTileOverlay.canReplaceMapContent = true
            mapView.addOverlay(gmTileOverlay, level: .aboveLabels)
        } catch let error {
            print(error.localizedDescription)
        }
    }

}

