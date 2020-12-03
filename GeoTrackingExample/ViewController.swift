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
    PhotoMarker(name:"AbolitionistPl", latitude: 40.692861, longitude: -73.986306, angle: 34),
    PhotoMarker(name:"GallatinPl", latitude: 40.691014, longitude: -73.986240, angle: 108),
    PhotoMarker(name:"GoldSt", latitude: 40.692106, longitude: -73.983442, angle:3),
    PhotoMarker(name:"Darna", latitude: 40.687066, longitude: -73.993732, angle: 0)
]

let audioMarkers  =  [
    AudioMarker(name:"AbolitionistPl", latitude: 40.692860, longitude: -73.986307, angle: 15),
]

class ViewController: UIViewController, ARSessionDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toastLabel: UILabel!
//    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var trackingStateLabel: UILabel!
    
    let coachingOverlay = ARCoachingOverlayView()
    
    let locationManager = CLLocationManager()
    
    var currentAnchors: [ARAnchor] {
        return arView.session.currentFrame?.anchors ?? []
    }
        
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
        
        // Load Reality Composer scene
//        let Experience = loadRealityComposerScene(filename: "Experience", fileExtension: "rcproject", sceneName: "Markers")
//        let PhotoMarker = Experience.loadRequest();
                
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
//    @IBAction func menuButtonTapped(_ sender: UIButton) {
//        presentAdditionalActions(sender)
//    }
    
    // Responds to a user tap on the AR view.
    @objc
    func handleTapOnARView(_ sender: UITapGestureRecognizer) {
//        let point = sender.location(in: view)
        showToast("AR Tap")
        
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
//        let point = sender.location(in: mapView)
//        let location = mapView.convert(point, toCoordinateFrom: mapView)
//        addGeoAnchor(at: location)
    }
    
    // Removes the most recent geo anchor.
//    @IBAction func undoButtonTapped(_ sender: Any) {
//        guard let lastGeoAnchor = geoAnchors.last else {
//            showToast("Nothing to undo")
//            return
//        }
//
//        // Remove geo anchor from the scene.
//        arView.session.remove(anchor: lastGeoAnchor.geoAnchor)
//
//        // Remove map overlay
//        mapView.removeOverlay(lastGeoAnchor.mapOverlay)
//
//        // Remove the element from the collection.
//        geoAnchors.removeLast()
//
//        showToast("Removed last added anchor")
//    }
    
    // MARK: - Methods
    
    // Presents the available actions when the user presses the menu button.
//    func presentAdditionalActions(_ sender: UIButton) {
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        actionSheet.popoverPresentationController?.sourceView = sender
//        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
//        actionSheet.addAction(UIAlertAction(title: "Reset Session", style: .destructive, handler: { (_) in
//            self.restartSession()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Load Anchors …", style: .default, handler: { (_) in
//            self.showGPXFiles()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Save Anchors …", style: .default, handler: { (_) in
//            self.saveAnchors()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(actionSheet, animated: true)
//    }
    
    // Calls into the function that saves any user-created geo anchors to a GPX file.
//    func saveAnchors() {
//        let geoAnchors = currentAnchors.compactMap({ $0 as? ARGeoAnchor })
//        guard !geoAnchors.isEmpty else {
//                alertUser(withTitle: "No geo anchors", message: "There are no geo anchors to save.")
//            return
//        }
//
//        saveAnchorsAsGPXFile(geoAnchors)
//    }

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
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        var text = geoTrackingStatus.state.description

        // In localized state, show geo tracking accuracy
        if geoTrackingStatus.state == .localized {
            text += ", Accuracy: \(geoTrackingStatus.accuracy.description)"
            
            for marker in photoMarkers {
                print("\(marker.latitude) : \(marker.longitude)")
                addGeoAnchor(at: CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude))
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
                                 fromDistance: CLLocationDistance(250),
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

