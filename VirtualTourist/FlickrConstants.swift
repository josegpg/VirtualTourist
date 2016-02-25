//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 1/25/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURL : String = "https://api.flickr.com/services/rest/"
        
    }
    
    // MARK: - Parameters values
    struct ParametersValues {
        
        // MARK: Session
        static let PhotosSearchMethod = "flickr.photos.search"
        static let ApiKey = "5045de9812e6b3fb41f888e05aaa42ea"
        static let DisableJsonCallBack = "1"
        static let JSONResponseFormat = "json"
        static let MediaURL = "url_m"
        
    }
    
    // MARK: - Parameters Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Format = "format"
        static let NoJsonCallback = "nojsoncallback"
        static let Method = "method"
        static let Extras = "extras"
        static let Page = "page"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Login
        static let Photos = "photos"
        static let Page = "page"
        static let TotalPages = "pages"
        static let PhotosPerPage = "perpage"
        static let Status = "stat"
        static let PhotoArray = "photo"
        static let MediaURL = "url_m"
        
    }
}