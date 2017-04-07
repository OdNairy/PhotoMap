//
//  Location.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import CoreLocation

class Location {
    var latitude: CGFloat
    var longitude: CGFloat
    var name: String
    var notes: String?
    var id = UUID().uuidString
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude),
                                      longitude: CLLocationDegrees(longitude))
    }
    
    init(latitude: CGFloat, longitude: CGFloat, name: String, notes: String? = nil, id: String? = nil){
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.notes = notes
        if let id = id {
            self.id = id
        }
    }

    
    func realmObject() -> LocationRealm {
        let locationRealm = LocationRealm()
        locationRealm.latitude = latitude
        locationRealm.longitude = longitude
        locationRealm.name = name
        locationRealm.notes = notes
        
        return locationRealm
    }
}



class LocationRealm: Object {
    dynamic var latitude: CGFloat = 0
    dynamic var longitude: CGFloat = 0
    dynamic var name = ""
    dynamic var notes: String?
    dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    func locationObject() -> Location {
        return Location(latitude: latitude, longitude: longitude, name: name, notes: notes, id: id)
    }

}
