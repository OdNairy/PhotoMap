//
//  PhotoMapTests.swift
//  PhotoMapTests
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import XCTest
import CoreLocation
@testable import PhotoMap


class PhotoMapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testMapListState() {
        let mapListVC = R.storyboard.main.mapList()!
        mapListVC.loadViewIfNeeded()
        XCTAssertEqual(mapListVC.contentType, .map)
        
        mapListVC.changeTypeButtonTap()
        XCTAssertEqual(mapListVC.contentType, .list)
        
        mapListVC.changeTypeButtonTap()
        mapListVC.changeTypeButtonTap()
        XCTAssertEqual(mapListVC.contentType, .list)
        
        mapListVC.changeTypeButtonTap()
        XCTAssertEqual(mapListVC.contentType, .map)
    }
    
    func testCreatePin() {
        let mapListVC = R.storyboard.main.mapList()!
        let stubService = DBServiceStub([])
        mapListVC.locationDBService = stubService
        mapListVC.loadViewIfNeeded()
        XCTAssertEqual(mapListVC.locations.count, 0)
        
        mapListVC.createPin(coordinate: CLLocationCoordinate2DMake(42, 18), name: "zero point")
        XCTAssertEqual(mapListVC.locations.count, 1)
        XCTAssertEqual(stubService!.saveCallCount, 1)
        
        let location = mapListVC.locations.first!
        XCTAssertEqual(location.name, "zero point")
        XCTAssertEqual(location.latitude, 42)
        XCTAssertEqual(location.longitude, 18)
        
        if let location = stubService?.allObjects().first {
            XCTAssertEqual(location.name, "zero point")
            XCTAssertEqual(location.latitude, 42)
            XCTAssertEqual(location.longitude, 18)
        }
    }
    
    func testDBUse() {
        
        let mapListVC = R.storyboard.main.mapList()!
        
        
        let stubService = DBServiceStub([])
        for _ in 0..<5 {
            stubService?.stubLocations.append(randomLocation())
        }
        mapListVC.locationDBService = stubService
        mapListVC.loadViewIfNeeded()
        
        XCTAssertEqual(mapListVC.locations.count, 5)
        
    }
    
    func testLocation() {
        let location = Location(latitude: 10, longitude: 20, name: "#@#å", notes: nil, id: nil)
        XCTAssertEqual(location.latitude, 10)
        XCTAssertEqual(location.longitude, 20)
        XCTAssertEqual(location.name, "#@#å")
        XCTAssertEqual(location.notes, nil)
        XCTAssertNotNil(location.id)
    }
    
    func testParseJSON(){
        let jsonURL = Bundle(for: type(of: self)).url(forResource: "100objects_test", withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let locations = try LocationsParser().parse(data: jsonData)
            XCTAssertNotNil(locations)
            
            XCTAssertEqual(locations!.count, 100)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testEmptyJSON(){
        do {
            let jsonData = "".data(using: .utf8)!
            let _ = try LocationsParser().parse(data: jsonData)
        } catch ParserError.keyNotFound(let key){
            XCTAssertEqual(key, "locations")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testWrongJSON(){
        do {
            let jsonData = "{\"locations\":[{\"nm\":\"Mike\"}]}".data(using: .utf8)!
            let locations = try LocationsParser().parse(data: jsonData)
            XCTAssertEqual(locations!.count, 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testPartitionalValuesInJSON(){
        do {
            let jsonData = "{\"locations\":[{\"name\":\"Mike\"}]}".data(using: .utf8)!
            let locations = try LocationsParser().parse(data: jsonData)
            XCTAssertEqual(locations!.count, 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCorrectValuesInJSON(){
        do {
            let jsonData = "{\"locations\":[{\"name\":\"Mike\",\"lat\":10,\"lng\":42}]}".data(using: .utf8)!
            let locations = try LocationsParser().parse(data: jsonData) ?? []
            XCTAssertEqual(locations.count, 1)
            let loc = locations.first!
            XCTAssertEqual(loc.name, "Mike")
            XCTAssertEqual(loc.latitude, CGFloat(10))
            XCTAssertEqual(loc.longitude, CGFloat(42))
            
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAdditionalValuesInJSON(){
        do {
            let jsonData = "{\"locations\":[{\"name\":\"Mike\",\"lat\":10,\"lng\":42,\"extrakey\":322}]}".data(using: .utf8)!
            let locations = try LocationsParser().parse(data: jsonData) ?? []
            XCTAssertEqual(locations.count, 1)
            let loc = locations.first!
            XCTAssertEqual(loc.name, "Mike")
            XCTAssertEqual(loc.latitude, CGFloat(10))
            XCTAssertEqual(loc.longitude, CGFloat(42))
            
        } catch {
            XCTAssertNil(error)
        }
    }
}


