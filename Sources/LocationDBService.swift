//
//  LocationDBService.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import Foundation
import RealmSwift

protocol DBService {
    associatedtype Entity
    
    init?(_ importers:[DBImporter])
    func save(_ entity:Entity)
    func update(_ entity:Entity)
    func processImport()
    
    func allObjects() -> [Entity]
}

class DBServiceClass<Entity>: DBService{
    required init?(_ importers: [DBImporter] = []) {}
    func save(_ entity: Entity) {}
    func update(_ entity: Entity) {}
    func processImport() {}
    func allObjects() -> [(Entity)] {
        return []
    }
}

final class LocationDBService: DBServiceClass<Location> {
    
    private var importers: [DBImporter]?
    
    let realm: Realm
    required init?(_ importers:[DBImporter] = [DefaultLocationsImporter()]){
        guard let realm = try? Realm() else { return nil }
        self.importers = importers
        self.realm = realm
        super.init(importers)
    }
    
    override func save(_ location: Location){
        let realmLocation = LocationRealm()
        realmLocation.latitude = location.latitude
        realmLocation.longitude = location.longitude
        realmLocation.name = location.name
        realmLocation.notes = location.notes
        
        do {
            try realm.write {
                realm.add(realmLocation)
            }
        } catch {
            print("Cannot save location in DB: \(error)")
        }
    }
    
    override func update(_ location: Location){
        if let realmLocation = realm.objects(LocationRealm.self).filter("id = '\(location.id)'").first {
            do {
                try realm.write {
                    realmLocation.notes = location.notes
                    
                }
                debugPrint("LocationRealm successfully updated")
            } catch {
                print("LocationRealm update was failed: \(error)")
            }
        }
    }
    
    private static let importLock = NSLock()
    override func processImport(){
        LocationDBService.importLock.lock()
        defer { LocationDBService.importLock.unlock() }
        
        importers?.filter{$0.shouldImport()}.forEach {
            $0.importToDatabase(realm: realm)
            debugPrint("Success import from \($0)")
        }
        importers = nil
    }
    
    override func allObjects() -> [Location] {
        return realm.objects(LocationRealm.self).map{ $0.locationObject()}
    }
}
