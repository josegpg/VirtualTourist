//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Jose Piñero on 2/24/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var pin: Pin!
    
    // For keeping collection view status
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Picture")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "relatedPin == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    override func viewDidLoad() {
        // Fetch stored photos
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // Set delegate
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Show status bar
        navigationController?.navigationBarHidden = false
        
        // Show map annotation
        showAnnotation()
        
        // Fetch photos if they dont exists  MOOoOoOoOOOooooooOOooooooooooooVE TO PREFETCH
        if pin.pictures.isEmpty && pin.searchInfo == nil {
            requestPhotos(0)
        } else {
            refreshInterface()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let space: CGFloat = 3.0
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        
        let width = floor((self.collectionView.frame.size.width - (2 * space))/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func showAnnotation() {
        let center = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
        let annotation = MKPointAnnotation()
        let newCamera = MKMapCamera(lookingAtCenterCoordinate: center, fromEyeCoordinate: center, eyeAltitude: CLLocationDistance(40000))
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        mapView.setCamera(newCamera, animated: true)
        mapView.userInteractionEnabled = false
    }
    
    func requestPhotos(page: Int) {
        FlickrClient.sharedInstance().searchPhotosNear(pin, page: page) {
            success, error in
            
            if success {
                self.refreshInterface()
            }
            
        }
    }
    
    func refreshInterface() {
        if pin.searchInfo!.totalNumberOfPages == 0 {
            dispatch_async(dispatch_get_main_queue()) {
                self.noImagesLabel.hidden = false
            }
        }
    }
    
    @IBAction func buttonButtonClicked() {
        
        if selectedIndexes.isEmpty {
            getNewCollection()
        } else {
            deleteSelectedPhotos()
        }
    }
    
    func getNewCollection() {
        
        // Delete all stored pictures
        for picture in fetchedResultsController.fetchedObjects as! [Picture] {
            picture.image = nil
            sharedContext.deleteObject(picture)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Get new page to consult
        let randomPage = getRandomPage(Int(pin.searchInfo!.totalNumberOfPages))
        requestPhotos(randomPage)
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Picture]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Picture)
        }
        
        for photo in photosToDelete {
            photo.image = nil
            sharedContext.deleteObject(photo)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        selectedIndexes = [NSIndexPath]()
        updateBottomButton()
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Photos"
        } else {
            bottomButton.title = "New Collection"
        }
    }
    
    func getRandomPage(total: Int) -> Int {
        return Int(arc4random_uniform(UInt32(total)))
    }
    
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCollectionCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
        updateBottomButton()
    }
    
    func configureCell(cell: ImageCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        cell.image.image = nil
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Picture
        var photoImage = UIImage(named: "placeholder")
        
        // configure whether the cell is selected or not
        if let _ = selectedIndexes.indexOf(indexPath) { cell.selectedView.hidden = false }
        else { cell.selectedView.hidden = true }
        
        if photo.image != nil {
            photoImage = photo.image
            cell.taskToCancelifCellIsReused = nil
        }
            
        else {
            
            // Start the task that will eventually download the image
            let task = FlickrClient.sharedInstance().taskForGetImage(photo.path) { data, error in
                
                if let error = error {
                    print("Photo download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    // Craete the image
                    let image = UIImage(data: data)
                    
                    // update the model, so that the infrmation gets cashed
                    photo.image = image
                    
                    // update the cell later, on the main thread
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.image.image = image
                    }
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.image.image = photoImage
    }
}

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
}