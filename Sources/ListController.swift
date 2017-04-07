//
//  ListController.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import UIKit
import CoreLocation

extension Location {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let selfLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return selfLocation.distance(from: otherLocation)
    }
}

final class ListController: UIViewController, LocationConfigurable {
    @IBOutlet weak var tableView: UITableView!
    var delegate: MapListCallbackProtocol?
    
    var locations: [Location] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configure(locations: [Location]?) {
        self.locations = locations ?? []
        if let userCoordinates = delegate?.userLocationCoordinates {

            let userLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
            self.locations = self.locations.sorted{ (loc1, loc2) -> Bool in
                let distance1 = CLLocation(latitude: CLLocationDegrees(loc1.latitude),
                                           longitude: CLLocationDegrees(loc1.latitude))
                    .distance(from: userLocation)
                let distance2 = CLLocation(latitude: CLLocationDegrees(loc2.latitude),
                                           longitude: CLLocationDegrees(loc2.latitude))
                    .distance(from: userLocation)
                
                return distance1 < distance2
            }
        }
        self.tableView.reloadData()
    }
}

extension ListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func location(for indexPath: IndexPath) -> Location{
        return locations[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.locationCell, for: indexPath)!
        cell.configure(location(for: indexPath), userCoordinates: delegate?.userLocationCoordinates)
        return cell
    }
}

extension ListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.openDetails(for: location(for: indexPath))
    }
}

final class LocationCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func configure(_ location: Location, userCoordinates: CLLocationCoordinate2D? = nil){
        titleLabel.text = location.name
        
        guard let userCoordinates = userCoordinates else {
            distanceLabel.text = nil
            return
        }
        let distance = Int(location.distance(to: userCoordinates))
        if distance >= 1000 {
            distanceLabel.text = "\(distance/1000) km"
        } else {
            distanceLabel.text = "\(distance) m"
        }
    }
}
