/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Extensions and helpers.
*/

import MapKit
import ARKit
import RealityKit

// A map overlay for geo anchors the user has added.
class AnchorIndicator: MKCircle {
    convenience init(center: CLLocationCoordinate2D) {
        self.init(center: center, radius: 3.0)
    }
}

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        get {
            return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
        }
        set (newValue) {
            columns.3.x = newValue.x
            columns.3.y = newValue.y
            columns.3.z = newValue.z
        }
    }
}

extension Entity {
    static func placemarkEntity(for arAnchor: ARAnchor, name: String, type: String, angle: Int) -> AnchorEntity {
        // Create base anchor to attatch entities to
        let placemarkAnchor = AnchorEntity(anchor: arAnchor)
        
        // Load Reality Composer Markers
        let rcAnchor = try! Experience.loadMarkers()
        
        // Add photo marker
        if(type == "photo"){
            let photoMarker = rcAnchor.photoPodium!
            let height = photoMarker.visualBounds(relativeTo: nil).extents.y
            // Transform marker down towards the ground
            photoMarker.position.y = -height*1.2
            // Add marker to anchor
            placemarkAnchor.addChild(photoMarker)
            
            // Generate photo plane geometry
            let mesh: MeshResource = .generatePlane(width: 0.8, depth: 0.3, cornerRadius: 0.05)
            // Generate photo plane material
            var texture = SimpleMaterial()
            texture.baseColor = try! .texture(.load(named: "texture"))
            texture.tintColor = UIColor.white
            let photoEntity = ModelEntity(mesh: mesh, materials: [texture])
            photoEntity.transform = Transform(pitch: .pi/4, yaw: .pi/2, roll: 0)
            let scale = SIMD3<Float>(x: 1, y: 1, z: 1)
            let rotation = simd_quatf(angle: .pi/4, axis: SIMD3(x: 1, y: 0, z: 0)) + simd_quatf(angle: .pi/2, axis: SIMD3(x: 0, y: 1, z: 0))
            let translation = SIMD3<Float>(x: 1, y: 0, z: 0)
            photoEntity.transform = Transform(scale: scale, rotation: rotation, translation: translation)
            // Add photo entity to anchor
            placemarkAnchor.addChild(photoEntity)
        }
        
        // Add audio marker
        else if(type == "audio"){
            let audioMarker = rcAnchor.speakerPole!
            let height = audioMarker.visualBounds(relativeTo: nil).extents.y
            // Transform marker down towards the ground
            audioMarker.position.y = -height
            // Add marker to anchor
            placemarkAnchor.addChild(audioMarker)
        }
        
        // Add info marker
        else if(type == "info"){
            let infoMarker = rcAnchor.infoBoard!
            let height = infoMarker.visualBounds(relativeTo: nil).extents.y
            // Transform marker down towards the ground
            infoMarker.position.y = -height
            // Add marker to anchor
            placemarkAnchor.addChild(infoMarker)
        }
        
        // Return generated anchor
        return placemarkAnchor
    }
    
    func move(by translation: SIMD3<Float>, scale: SIMD3<Float>, after delay: TimeInterval, duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            var transform: Transform = .identity
            transform.translation = self.transform.translation + translation
            transform.scale = self.transform.scale * scale
            self.move(to: transform, relativeTo: self.parent, duration: duration, timingFunction: .easeInOut)
        }
    }
}

extension ViewController {
    func alertUser(withTitle title: String, message: String, actions: [UIAlertAction]? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let actions = actions {
                actions.forEach { alert.addAction($0) }
            } else {
                alert.addAction(UIAlertAction(title: "OK", style: .default))
            }
            self.present(alert, animated: true)
        }
    }
    
    func showToast(_ message: String, duration: TimeInterval = 2) {
        DispatchQueue.main.async {
            self.toastLabel.numberOfLines = message.components(separatedBy: "\n").count
            self.toastLabel.text = message + self.toastLabel.text! ?? ""
            self.toastLabel.isHidden = false
            
            // use tag to tell if label has been updated
            let tag = self.toastLabel.tag + 1
            self.toastLabel.tag = tag
            
            if duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    // Do not hide if showToast is called again, before this block kicks in.
                    if self.toastLabel.tag == tag {
                        self.toastLabel.isHidden = true
                    }
                }
            }
        }
    }
}

extension ARGeoTrackingStatus.State {
    var description: String {
        switch self {
        case .notAvailable: return "Not available"
        case .initializing: return "Initializing"
        case .localizing: return "Localizing"
        case .localized: return "Localized"
        @unknown default: return  "Unknown"
        }
    }
}

extension ARGeoTrackingStatus.StateReason {
    var description: String {
        switch self {
        case .none: return "None"
        case .notAvailableAtLocation: return "Geo tracking is unavailable here. Please return to your previous location to continue"
        case .needLocationPermissions: return "App needs location permissions"
        case .worldTrackingUnstable: return "Limited tracking"
        case .geoDataNotLoaded: return "Downloading localization imagery. Please wait"
        case .devicePointedTooLow: return "Point the camera at a nearby building"
        case .visualLocalizationFailed: return "Point the camera at a building unobstructed by trees or other objects"
        case .waitingForLocation: return "ARKit is waiting for the system to provide a precise coordinate for the user"
        case .waitingForAvailabilityCheck: return "ARKit is checking Location Anchor availability at your locaiton"
        @unknown default: return "Unknown reason"
        }
    }
}

extension ARGeoTrackingStatus.Accuracy {
    var description: String {
        switch self {
        case .undetermined: return "Undetermined"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        @unknown default: return "Unknown"
        }
    }
}

extension ARCamera.TrackingState.Reason {
    var description: String {
        switch self {
        case .initializing: return "Initializing"
        case .excessiveMotion: return "Too much motion"
        case .insufficientFeatures: return "Insufficient features"
        case .relocalizing: return "Relocalizing"
        @unknown default: return "Unknown"
        }
    }
}
