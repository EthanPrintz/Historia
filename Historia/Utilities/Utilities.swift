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
            photoMarker.name = name
            // Add marker to anchor
            placemarkAnchor.addChild(photoMarker)
            
            // Generate photo plane geometry
            let mesh: MeshResource = .generatePlane(width: 0.75, depth: 0.45, cornerRadius: 0.02)
            // Generate photo plane material
            var texture = SimpleMaterial()
            texture.baseColor = try! .texture(.load(named: name))
            texture.tintColor = UIColor.white.withAlphaComponent(0.99)
            let photoEntity = ModelEntity(mesh: mesh, materials: [texture])
            photoEntity.transform = Transform(pitch: .pi*3/18, yaw: .pi/2, roll: 0)
            photoEntity.transform.translation += SIMD3<Float>(x: 0, y: -0.36, z: -0.95)
            photoEntity.name = name
            // Add photo entity to anchor
            placemarkAnchor.addChild(photoEntity)
        }
        
        // Add audio marker
        else if(type == "audio"){
            let audioMarker = rcAnchor.speakerPole!
            let height = audioMarker.visualBounds(relativeTo: nil).extents.y
            // Transform marker down towards the ground
            audioMarker.position.y = -height
            audioMarker.name = name
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
        
        let anchorIndex = markers.firstIndex(where: { (marker) -> Bool in marker.name == name})!
        let anchorAngle = markers[anchorIndex].angle

        // Rotates anchor to match world placement, (0 = E>W, 90 = S>N)
        placemarkAnchor.transform = Transform(pitch: 0, yaw: deg2rad(anchorAngle), roll: 0)
        
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

func deg2rad(_ number: Int) -> Float {
    return Float(number) * .pi / 180
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
            self.toastLabel.font = newYorkFont
            self.toastLabel.text = message
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

// From https://mic.st/blog/how-to-use-new-ios-13-system-fonts-like-new-york/
var newYorkFont: UIFont {
/// 1. Initialize a system font with the preferred size and weight and access its `fontDescriptor` property.
      let descriptor = UIFont.systemFont(ofSize: 18,
                                         weight: .semibold).fontDescriptor

/// 2. Use the new iOS13 `withDesign` to get the `UIFontDescriptor` for a serif version of your system font. The size is derived from your initial `UIFont` so set it to `0.0`
      if let serif = descriptor.withDesign(.serif) {
        return UIFont(descriptor: serif, size: 0.0)
      }

/// 3. Initialize a font with the serif descriptor of your system font. Again: use `0.0` as `size` parameter to prevent overriding the initial size we did set above.
      return UIFont(descriptor: descriptor, size: 0.0)
}

// From https://mic.st/blog/how-to-use-new-ios-13-system-fonts-like-new-york/
var newYorkFontSmall: UIFont {
/// 1. Initialize a system font with the preferred size and weight and access its `fontDescriptor` property.
      let descriptor = UIFont.systemFont(ofSize: 15,
                                         weight: .semibold).fontDescriptor

/// 2. Use the new iOS13 `withDesign` to get the `UIFontDescriptor` for a serif version of your system font. The size is derived from your initial `UIFont` so set it to `0.0`
      if let serif = descriptor.withDesign(.serif) {
        return UIFont(descriptor: serif, size: 0.0)
      }

/// 3. Initialize a font with the serif descriptor of your system font. Again: use `0.0` as `size` parameter to prevent overriding the initial size we did set above.
      return UIFont(descriptor: descriptor, size: 0.0)
}

