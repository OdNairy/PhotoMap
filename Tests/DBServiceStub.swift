//
//  DBServiceStub.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/7/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import Foundation
import CoreGraphics
@testable import PhotoMap

final class DBServiceStub: DBServiceClass<Location> {
    convenience init?(locations: [Location]) {
        self.init([])
        stubLocations = locations
    }
    var stubLocations: [Location] = []
    override func allObjects() -> [(Location)] {
        return stubLocations
    }
    
    var saveCallCount = 0
    override func save(_ entity: Location) {
        saveCallCount += 1
        stubLocations.append(entity)
    }
    
    override func update(_ entity: Location) {
        
    }
}

func stubbedData(_ locations:[Location] = []) -> (mapList: MapListContainerController, dbStub: DBServiceStub){
    let mapListVC = R.storyboard.main.mapList()!
    
    let stubService = DBServiceStub(locations: locations)!
    mapListVC.locationDBService = stubService
    mapListVC.loadViewIfNeeded()
    
    return (mapListVC, stubService)
}

func randomLocation() -> Location {
    return Location(latitude: CGFloat(arc4random_uniform(40)),
                    longitude: CGFloat(arc4random_uniform(40)), name: "")
}
