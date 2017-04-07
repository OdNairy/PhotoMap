//
//  MapController.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import UIKit
import MapKit

class LocationPointAnnotation: MKPointAnnotation {
    var location: Location?
}

final class MapController: UIViewController, LocationConfigurable {
    @IBOutlet weak var mapView: MKMapView!
    var delegate: MapListCallbackProtocol?
    
    
    var appearFirstTime = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if appearFirstTime == false {
            appearFirstTime = true
            mapView.showAnnotations(mapView.annotations, animated: animated)
        }
    }
    
    func configure(locations: [Location]?) {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let locations = locations, locations.count > 0 else { return }
        
        let annotations = locations.map { location -> MKAnnotation in
            let annotation = LocationPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = location.coordinates
            annotation.location = location
            
            return annotation
        }
        
        mapView.addAnnotations(annotations)
    }
    @IBAction func addNewPin(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let touchPoint = sender.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        requestNameForPin(coordinates: coordinates)
    }
    
    func requestNameForPin(coordinates: CLLocationCoordinate2D){
        let alert = UIAlertController(title: "New Pin", message: "Name your pin", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (_) in
            if let name = alert.textFields?.first?.text {
                self.createNewPin(coordinates: coordinates, name: name)
                print(name)
            }
            
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func createNewPin(coordinates: CLLocationCoordinate2D, name: String, notes: String? = nil) {
        delegate?.createPin(coordinate: coordinates, name: name, notes: notes)
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil}
        
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
            ?? defaultPinAnnotationView(annotation: annotation)
        

        return pinView
    }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let locationAnnotation = view.annotation as? LocationPointAnnotation,
            let location = locationAnnotation.location else { return }
        delegate?.openDetails(for: location)
    }
    
    func defaultPinAnnotationView(annotation: MKAnnotation, reuseIdentifier: String = "pin") -> MKPinAnnotationView {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return pinView
    }
}

