//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentAddingPin: CustomAnnotation?
    var tappedPin: Pin?
    var pins: [Pin] = []
    
    // MARK: - Shared Context
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    struct MapStateStorageKeys {
        static let Altitude = "mapAltitude"
        static let Latitude = "mapLatitude"
        static let Longitude = "mapLongitude"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch all pins
        pins = fetchAllPins()
        
        // Add all needed to the map
        setUpMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide Navigation Bar
        navigationController?.navigationBarHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Ok", style: .Plain, target: nil, action: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Set coordinates of the map to show in the next VC
        if let destinationVC = segue.destinationViewController as? CollectionViewController {
            destinationVC.pin = tappedPin
        }
    }
    
    func setUpMap() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")

        // Add long press gesture recongnizer to the map
        mapView.addGestureRecognizer(longPressGesture)
        
        // Add previous annotations
        addCurrentPinsToMap()
        
        // Restore previous camera
        getMapCamera()
        
    }
    
    func addAnnotation(recognizer: UIGestureRecognizer) {
        
        let touchPoint = recognizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        if let curAnnotation = currentAddingPin {
            curAnnotation.coordinate = coordinate
        }
        
        if recognizer.state == .Ended {
            saveCurrentPin()
        } else if recognizer.state == .Began {
            let annotation = CustomAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            currentAddingPin = annotation
        }
    }
    
    func addCurrentPinsToMap() {
        var arrayOfAnnotations:[CustomAnnotation] = []
        for (index, pin) in pins.enumerate() {
            let annotation = CustomAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
            annotation.arrayIndex = index
            
            arrayOfAnnotations.append(annotation)
        }
        
        mapView.addAnnotations(arrayOfAnnotations)
    }
    
    // MARK: Functions to store and fetch data
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [Pin]()
        }
    }
    
    func saveCurrentPin() {
        if let currentAddingPin = self.currentAddingPin {
            sharedContext.performBlock {
                
                // Store Pin in core data
                let newPin = Pin(lat: currentAddingPin.coordinate.latitude, lng: currentAddingPin.coordinate.longitude, context: self.sharedContext)
                
                currentAddingPin.arrayIndex = self.pins.count
                
                // Add the new pin to the array
                self.pins.append(newPin)
                
                // Get info if possible
                FlickrClient.sharedInstance().searchPhotosNear(newPin, page: 0) { success, error in }
                
                CoreDataStackManager.sharedInstance().saveContext()
                
                self.currentAddingPin = nil
            }
        }
    }
    
    func saveMapCamera() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Save the center and altitude of the map
        defaults.setDouble(mapView.camera.altitude, forKey: MapStateStorageKeys.Altitude)
        defaults.setDouble(mapView.camera.centerCoordinate.latitude, forKey: MapStateStorageKeys.Latitude)
        defaults.setDouble(mapView.camera.centerCoordinate.longitude, forKey: MapStateStorageKeys.Longitude)
    }

    func getMapCamera() {
        // Read the current value for the "myValue" key
        let defaults = NSUserDefaults.standardUserDefaults()
        let altitude = defaults.doubleForKey(MapStateStorageKeys.Altitude)
        let latitude = defaults.doubleForKey(MapStateStorageKeys.Latitude)
        let longitude = defaults.doubleForKey(MapStateStorageKeys.Longitude)
        
        // If there is something stored then update camera
        if latitude != 0 && longitude != 0 {
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let storedCamera = MKMapCamera(lookingAtCenterCoordinate: center, fromEyeCoordinate: center, eyeAltitude: CLLocationDistance(altitude))
            
            mapView.setCamera(storedCamera, animated: false)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // Deselect the selected annotation
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let tappedAnnotation = view.annotation as! CustomAnnotation
        tappedPin = pins[tappedAnnotation.arrayIndex]
        
        performSegueWithIdentifier("showImageCollection", sender: self)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Store map camera state
        saveMapCamera()
    }

}