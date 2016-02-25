//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    // MARK: GET convenience methods
    
    // Search photos using a page
    func searchPhotosNear(pin: Pin, page: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            ParameterKeys.ApiKey: ParametersValues.ApiKey,
            ParameterKeys.Format: ParametersValues.JSONResponseFormat,
            ParameterKeys.Latitude: Double(pin.latitude),
            ParameterKeys.Longitude: Double(pin.longitude),
            ParameterKeys.Method: ParametersValues.PhotosSearchMethod,
            ParameterKeys.NoJsonCallback: ParametersValues.DisableJsonCallBack,
            ParameterKeys.Extras: ParametersValues.MediaURL,
            ParameterKeys.Page: page
        ]
        
        taskForGETMethod("", parameters: parameters) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else if let response = PhotosResponse(dictionary: JSONResult as! [String : AnyObject]) {
                
                // Save photos
                for dictionary in response.photosDictionaries {
                    let picture = Picture(dictionary: dictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                    picture.relatedPin = pin
                }
                
                // Save Search Info
                let searchInfo = SearchInfo(totalNumberOfPages: response.totalPages, photosPerPage: response.photosPerPage, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                searchInfo.relatedPin = pin
                
                // Save context
                CoreDataStackManager.sharedInstance().saveContext()
                
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: APIClient.createError("searchFlickrPhotos parsing", msg: "Could not parse searchFlickrPhotos"))
            }
        }
        
    }
    
    func taskForGetImage(url: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionDataTask {
        let url = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: url)
        
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = APIClient.errorForData(data, response: response, error: error)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
}