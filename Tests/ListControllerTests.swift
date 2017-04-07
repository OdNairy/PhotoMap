//
//  ListControllerTests.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/7/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import Foundation
import XCTest
import CoreLocation
@testable import PhotoMap

class ListControllerTests: XCTestCase {
    
    
    
    func testBasicRows(){
        let stubData = stubbedData()
        let mapListVC = stubData.mapList
        mapListVC.changeTypeButtonTap()
        XCTAssertEqual(mapListVC.contentType, .list)
        
        XCTAssertNotNil(mapListVC.currentChildVC)
        XCTAssertNoThrow(mapListVC.currentChildVC as! ListController)
        
        let listChild = mapListVC.currentChildVC as! ListController
        listChild.loadViewIfNeeded()
        
        
        XCTAssertEqual(listChild.tableView.numberOfSections, 1)
        XCTAssertEqual(listChild.tableView.numberOfRows(inSection: 0), 0)
    }
    
    func testOneLocation(){
        let randomLoc = randomLocation()
        
        let stubData = stubbedData([randomLoc])
        let mapListVC = stubData.mapList
        mapListVC.changeTypeButtonTap()
        XCTAssertEqual(mapListVC.contentType, .list)
        
        XCTAssertNotNil(mapListVC.currentChildVC)
        XCTAssertNoThrow(mapListVC.currentChildVC as! ListController)
        
        let listChild = mapListVC.currentChildVC as! ListController
        listChild.loadViewIfNeeded()
        
        
        XCTAssertEqual(listChild.tableView.numberOfSections, 1)
        XCTAssertEqual(listChild.tableView.numberOfRows(inSection: 0), 1)
        
        let firstCell = listChild.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(firstCell)
        XCTAssertTrue(firstCell is LocationCell)
        let cell = firstCell as! LocationCell
        XCTAssertEqual(cell.titleLabel.text, randomLoc.name)
    }
    
    
    func testSortLocations(){
        let userLocation = CLLocationCoordinate2DMake(0, 0)
        
        let locations = (0...400).map { Location(latitude: CGFloat($0)/10, longitude: 0, name: String(format: "%zd test location", $0) )}
        let reversedLocations = locations.reversed()
        
        let sortedLocations = reversedLocations.sort(for: userLocation)
        XCTAssertEqual(sortedLocations, locations)
    }
    
    func testControllerWithNonsortedLocations(){
        let randomLocations = (0..<100).map { _ in randomLocation() }
        let data = stubbedData(randomLocations)
        let locationStub = LocationManagerStub(latitude: 15, longitude: 20)
        data.mapList.locationManager = locationStub
        data.mapList.changeTypeButtonTap()
        XCTAssertEqual(data.mapList.contentType, .list)
        
        let sortedLocations = randomLocations.sort(for: locationStub.location!.coordinate)
        
        let listController = data.mapList.currentChildVC as! ListController
        
        XCTAssertEqual(listController.tableView.numberOfRows(inSection: 0), 100)
        
        var previousDistance: CLLocationDistance = -1
        
        for i in 0..<listController.tableView.numberOfRows(inSection: 0) {
            let indexpath = IndexPath(row: i, section: 0)
            XCTAssertEqual(listController.location(for: indexpath), sortedLocations[i])
            let locationCell = listController.tableView(listController.tableView, cellForRowAt: indexpath) as! LocationCell
            XCTAssertNotNil(locationCell)
            
            XCTAssertNotNil(locationCell.location)
            
            let location = locationCell.location!
            
            let distance = location.distance(to: locationStub.location!.coordinate)
            XCTAssertGreaterThanOrEqual(distance, previousDistance)
            
            previousDistance = distance
        }
    }
}

class UBLA: UITableViewCell {
    
}
