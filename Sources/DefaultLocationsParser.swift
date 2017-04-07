//
//  DefaultLocationsParser.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import RealmSwift

protocol DBImporter {
    func shouldImport() -> Bool
    func importToDatabase(realm: Realm)
}

enum ImportError: Error {
    case pathNotResolved, noFileExists
    case parsingFailed
}

enum ParserError: Error {
    case failedByUnknownReason
    case keyNotFound(String)
}

final class DefaultLocationsImporter: DBImporter {
    let parser: LocationsParser
    
    init(_ parser: LocationsParser = LocationsParser()){
        self.parser = parser
    }
    
    static let importKeyName = "DefaultLocationsImporter.ImportSuccessfully"
    func shouldImport() -> Bool {
        guard nil != UserDefaults.standard.object(forKey: DefaultLocationsImporter.importKeyName) else {return true}
        return !UserDefaults.standard.bool(forKey: DefaultLocationsImporter.importKeyName)
    }
    
    func importToDatabase(realm: Realm) {
        do {
            guard let defaultLocationsURL = R.file.locationsJson() else { throw ImportError.pathNotResolved }
            guard FileManager.default.fileExists(atPath: defaultLocationsURL.path) else { throw ImportError.noFileExists }
            
            let locationsData = try Data(contentsOf: defaultLocationsURL)
            
            guard let parsedLocations = try parser.parse(data: locationsData) else { throw ParserError.failedByUnknownReason }
            
            let realmObjects = parsedLocations.map{ $0.realmObject() }
            try realm.write {
                realm.add(realmObjects)
            }
            UserDefaults.standard.set(true, forKey: DefaultLocationsImporter.importKeyName)
            UserDefaults.standard.synchronize()
        } catch ImportError.pathNotResolved {
            debugPrint("Skipping import locations (no file exists)")
        } catch  {
            print("Error during import: \(error)")
        }
    }
}

class LocationsParser {
    
    func parse(data locationsData: Data) throws -> [Location]? {
        guard let locationsJSON = JSON(data: locationsData)["locations"].array else { throw ParserError.keyNotFound("locations") }
        
        let locations = locationsJSON.map { locationJSON -> Location? in
            guard let latitude = locationJSON["lat"].double,
                let longitude = locationJSON["lng"].double,
                let name = locationJSON["name"].string else {
                    debugPrint("Cannot parse JSON: \(locationJSON)")
                    return nil
            }
            
            return Location(latitude: CGFloat(latitude), longitude: CGFloat(longitude), name: name)
        }.flatMap{ $0 }
        

        return locations
    }
}
