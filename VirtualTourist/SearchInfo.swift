//
//  SearchInfo.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/25/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData

class SearchInfo: NSManagedObject {
    
    @NSManaged var totalNumberOfPages: NSNumber
    @NSManaged var photosPerPage: NSNumber
    @NSManaged var relatedPin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(totalNumberOfPages: NSNumber, photosPerPage: NSNumber, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("SearchInfo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.totalNumberOfPages = totalNumberOfPages
        self.photosPerPage = photosPerPage
    }
}
