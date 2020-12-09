//
//  HistoriaGeoAnchor.swift
//  Historia
//
//  Created by Ethan Printz on 12/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RealityKit
import ARKit
import MapKit

protocol ExtendedGeoAnchor {
    var name: String { get }
    var coordinate: CLLocationCoordinate2D {get}
    var type: String { get }
    var angle: Int { get }
    var marker: ARGeoAnchor { get }
}

class HistoriaAnchor: ExtendedGeoAnchor{
    var name: String
    var coordinate: CLLocationCoordinate2D
    var type: String
    var angle: Int
    var marker: ARGeoAnchor
    
    init(name: String, coordinate: CLLocationCoordinate2D, type: String, angle: Int){
        self.name = name
        self.coordinate = coordinate
        self.type = type
        self.angle = angle
        self.marker = ARGeoAnchor(coordinate: coordinate)
    }
}
