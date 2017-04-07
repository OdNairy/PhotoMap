//
//  ViewController.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import UIKit
import MapKit
import ObjectMapper
import RealmSwift
import SwiftyJSON

protocol Containable: class, UIViewControllerType {}
extension String: Error {}


final class MapListContainerController: UIViewController {
    enum ContentType {
        case map, list
    }
    var contentType = ContentType.map

    @IBOutlet weak var changeTypeButton: UIBarButtonItem!
    @IBAction func changeTypeButtonTap(_ sender: Any? = nil) {
        switch contentType {
        case .map:
            contentType = .list
            changeTypeButton.title = "Map"
            
            configureViewPresentation(childVC: R.storyboard.main.locationsList()!)
        case .list:
            contentType = .map
            changeTypeButton.title = "List"
            configureViewPresentation(childVC: R.storyboard.main.locationsMap()!)
        }
        configureViewData()
    }
    
    var locations: [Location] = []
    var locationDBService: DBServiceClass? = LocationDBService()
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationDBService?.processImport()
        locationManager.startUpdatingLocation()
        
        configureViewPresentation(childVC: R.storyboard.main.locationsMap()!)
        configureViewData()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if let locations = locationDBService?.allObjects() {
            self.locations.append(contentsOf: locations)
        }
    }
    
    var currentChildVC: UIViewController?
    func configureViewPresentation(childVC: UIViewController) {
        currentChildVC?.removeFromParentViewController()
        currentChildVC?.view.removeFromSuperview()
        
        currentChildVC = childVC
        addChildViewController(childVC)
        view.addSubview(childVC.view)
        childVC.view.topAnchor.constraint(equalTo: view.topAnchor)
        childVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        childVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        childVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
    }
    
    func configureViewData(useCache: Bool = false){
        guard let currentChildVC = currentChildVC, currentChildVC is LocationConfigurable else {return}
        
        var locationConfigurable = (currentChildVC as! LocationConfigurable)
        locationConfigurable.delegate = self
        if useCache {
            locationConfigurable.configure(locations: locations)
        } else {
            locationConfigurable.configure(locations: locationDBService?.allObjects())
        }
    }
    
}

extension MapListContainerController: MapListCallbackProtocol {
    func createPin(coordinate: CLLocationCoordinate2D, name: String, notes: String? = nil) {
        let pinLocation = Location(latitude: CGFloat(coordinate.latitude),
                           longitude: CGFloat(coordinate.longitude),
                           name: name, notes: notes)
        locationDBService?.save(pinLocation)
        locations.append(pinLocation)
        configureViewData()
    }
    
    var userLocationCoordinates: CLLocationCoordinate2D?{
        return locationManager.location?.coordinate
    }
    
    func openDetails(for location: Location) {
        performSegue(withIdentifier: R.segue.mapListContainerController.openDetails, sender: location)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let location = sender as? Location,
              let typedInfo = R.segue.mapListContainerController.openDetails(segue: segue) else { return }
        typedInfo.destination.location = location
    }
}

protocol MapListCallbackProtocol{
    var userLocationCoordinates: CLLocationCoordinate2D? {get}
    func createPin(coordinate: CLLocationCoordinate2D, name: String, notes: String?)
    
    func openDetails(for location:Location)
}

protocol LocationConfigurable {
    var delegate: MapListCallbackProtocol? {get set}
    func configure(locations: [Location]?)
}

class MapView: UIView {
    @IBOutlet weak var mkMapView: MKMapView!
    
    override func awakeFromNib() {
        mkMapView.delegate = self // implemented in extension
    }
    
    func configure(locations: [Location]) {
        let annotations = locations.map { location -> MKAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = location.coordinates
            
            return annotation
        }
        
        mkMapView.addAnnotations(annotations)
    }
}

extension MapView: MKMapViewDelegate {
    
}

