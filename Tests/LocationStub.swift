//
//  LocationStub.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/7/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import Foundation
import CoreLocation
@testable import PhotoMap

class LocationManagerStub: LocationManager {
    var location: CLLocation?
    
    init(latitude: Double, longitude: Double){
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    func requestWhenInUseAuthorization() {
        
    }
    func startUpdatingLocation() {
        
    }
}
