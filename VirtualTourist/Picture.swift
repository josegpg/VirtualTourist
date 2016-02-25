//
//  Picture.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Picture: NSManagedObject {
    
    struct Keys {
        static let Path = "url_m"
        static let Title = "title"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var path: String
    @NSManaged var title: String
    @NSManaged var relatedPin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], id: NSNumber, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        path = dictionary[Keys.Path] as! String
        title = dictionary[Keys.Title] as! String
        self.id = id
    }
    
    var image: UIImage? {
        get { return FlickrClient.Caches.imageCache.imageWithIdentifier(path) }
        set { FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: path) }
    }
}
