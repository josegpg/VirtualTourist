//
//  Pin.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var pictures: [Picture]
    @NSManaged var searchInfo: SearchInfo?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: NSNumber, lng: NSNumber, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = lat
        longitude = lng
    }
}
