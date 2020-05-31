//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 26/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnNewCollection: UIButton!
    
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var dataController: DataController?
    
    
    var photos: [FlickrPhoto] = []
    var pin: Pin?
    
    lazy var itemSize: CGSize = {
        let collectionWidth = UIScreen.main.bounds.width / 3 - 2
        let itemWidth = collectionWidth
        return CGSize(width: itemWidth, height: 120)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupFetchedResultsController {
            self.getPhotos()
        }
    }
    
    private func setupFetchedResultsController(completion: @escaping (() -> Void)) {
        guard let dataController = dataController else {
            return
        }
        guard let pin = pin, let location = pin.location else {
            return
        }
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "latitude == %lf && location == %@", pin.latitude, location)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "location", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            completion()
        } catch  {
            fatalError("The fetch could not be performed! \(error.localizedDescription)")
        }
    }
    
    private func getPhotos() {
        guard let dataController = dataController else { return }
        let photosSavedCount = fetchedResultsController.fetchedObjects?.first?.photos?.count ?? 0
        if photosSavedCount == 0 {
            getFlickerPhotos { (photos, error) in
                guard let photos = photos else { debugPrint("Show error message")
                    return
                }
                photos.forEach { (flickr: FlickrPhoto) in
                    let photo = Photo(context: dataController.viewContext)
                    photo.data = flickr.thumbnail?.pngData()
                    photo.photoID = flickr.photoID
                    photo.url = flickr.flickrImageURL()?.absoluteString
                    photo.pin = self.pin
                    if dataController.viewContext.hasChanges {
                        try? dataController.viewContext.save()
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    private func getFlickerPhotos(completion: @escaping (([FlickrPhoto]?, Error?) -> Void)) {
        guard let location = pin?.location else { return }
        Flickr().searchFlickr(for: location) { (result: Result<FlickrSearchResults>) in
            switch result {
            case .results(let result):
                completion(result.searchResults, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }

}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.first?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let photos = fetchedResultsController.fetchedObjects?.first?.photos?.allObjects as? [Photo] else { return UICollectionViewCell() }
        
        let photo = photos[indexPath.row]
        
        if let url = photo.url {
            cell.loadImageBy(url: url)
        } else {
            cell.loadImageBy(data: photo.data)
        }
        return cell
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
     
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionView.performBatchUpdates(nil, completion: nil)
//    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [indexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        default:
            break
        }
        
    }
}
