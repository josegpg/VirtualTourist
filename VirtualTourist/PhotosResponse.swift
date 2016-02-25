//
//  PhotosResponse.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation

class PhotosResponse {
    var page : Int = 0
    var totalPages: Int = 0
    var photosPerPage: Int = 0
    var photosDictionaries: [[String: AnyObject]] = []
    
    init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let photsDictionary = dictionary[FlickrClient.JSONResponseKeys.Photos] as? [String : AnyObject] {
            
            if let page = photsDictionary[FlickrClient.JSONResponseKeys.Page] as? Int {
                self.page = page
            } else {return nil}
            
            if let totalPages = photsDictionary[FlickrClient.JSONResponseKeys.TotalPages] as? Int {
                self.totalPages = totalPages
            } else {return nil}
            
            if let photosPerPage = photsDictionary[FlickrClient.JSONResponseKeys.PhotosPerPage] as? Int {
                self.photosPerPage = photosPerPage
            } else {return nil}
            
            if let photos = photsDictionary[FlickrClient.JSONResponseKeys.PhotoArray] as? [[String: AnyObject]] {
                photosDictionaries = photos
            } else {return nil}
            
        } else { return nil }
    }
}