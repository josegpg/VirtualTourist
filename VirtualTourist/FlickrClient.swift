//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation

class FlickrClient : APIClient {
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    override func getBaseUrl() -> String {
        return Constants.BaseURL
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
}