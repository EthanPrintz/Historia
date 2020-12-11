//
//  Markers.swift
//  Historia
//
//  Created by Ethan Printz on 12/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

struct Marker {
    var name: String
    var type: String
    var latitude: Double
    var longitude: Double
    var angle: Int
}
struct Description {
    var name: String
    var type: String
    var date: String
    var description: String
    var source: String
}

let markers  =  [
    // Test Markers
    Marker(name: "111Lawrence", type: "photo", latitude: 40.69270997971054, longitude: -73.98618571934942, angle: 0),
    Marker(name: "116Lawrence", type: "photo", latitude: 40.692798705576735, longitude: -73.9863043651857, angle: 0),
    Marker(name: "111LawrenceA", type: "audio", latitude: 40.69269411087816,  longitude: -73.98618563769263, angle: 90),
    // Real Markers
    Marker(name: "LawrenceWilloughbyTrees", type: "photo", latitude: 40.69177098404329,  longitude: -73.9862508123362, angle: 30),
    Marker(name: "LawrenceSnow", type: "photo", latitude: 40.6921429687817,  longitude:  -73.98617248834888, angle: 0),
    Marker(name: "WilloughbyEast", type: "photo", latitude: 40.69214549663425,  longitude: -73.98610596801356, angle: 90),
]

let descriptions = [
    Description(name: "111Lawrence", type: "photo", date: "2020-12-10", description: "The birthplace of Historia", source: "Ethan Printz"),
    Description(name: "116Lawrence", type: "photo", date: "2020-12-10", description: "The birthplace of Historia", source: "Ethan Printz"),
    Description(name: "LawrenceWilloughbyTrees", type: "photo", date: "1906-06-08", description: "Lawrence street filled with debris, nearby elevated rail seen in background", source: "New York Transit Museum"),
    Description(name: "LawrenceSnow", type: "photo", date: "1916-03-16", description: "A snowy day on Willoughby coats the subway construction equipment in a fresh layer of powder.", source: "New York Transit Museum"),
    Description(name: "WilloughbyEast", type: "photo", date: "1924-04-04", description: "Description", source: "New York Transit Museum"),
]
