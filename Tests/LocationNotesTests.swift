//
//  LocationNotesTests.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/7/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import XCTest
@testable import PhotoMap

class LocationNotesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotesLocation(){
        let locations = (0...10).map { _ in randomLocation() }
        let data = stubbedData(locations)
        XCTAssertNotNil(data.mapList.currentChildVC)
        XCTAssert(data.mapList.currentChildVC is MapController)
        let map = data.mapList.currentChildVC as! MapController
        
        let navigation = UINavigationController(rootViewController: data.mapList)
        XCTAssertNotNil(navigation)
        
        let annotation = map.mapView.annotations.first as! LocationPointAnnotation
        map.delegate?.openDetails(for: annotation.location!)
        let notesExpectation = self.expectation(description: "present Notes VC");
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { 
            notesExpectation.fulfill()
        }
    
        wait(for: [notesExpectation], timeout: 2)
        
        XCTAssert(data.mapList.navigationController!.topViewController is LocationNotesController)
        let notesVC = data.mapList.navigationController!.topViewController as! LocationNotesController
        notesVC.loadViewIfNeeded()
        XCTAssertEqual(notesVC.location, annotation.location)
//        map.mapView(map.mapView, annotationView: annotation, calloutAccessoryControlTapped: UIButton(type: UIButtonType.detailDisclosure))
        
        notesVC.textView.text = "test text"
        notesVC.saveButtonTap(notesVC)
        XCTAssertEqual(notesVC.location!.notes, "test text")
    }
    
    
    
    func testRswift(){
        XCTAssertNoThrow(try R.validate())
    }
    
}
