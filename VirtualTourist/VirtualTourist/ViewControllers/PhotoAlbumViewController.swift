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
    
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController: DataController?
    var pin: Pin?
    var page: Int = 1
    
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
            if self.fetchedResultsController.fetchedObjects?.count == 0 {
                self.getPhotos()
            } else { self.showLoading(show: false) }
        }
    }
    
    @IBAction func getNewAlbum(_ sender: Any) {
        guard let photos = fetchedResultsController.fetchedObjects else { return }
        if !Reachability.isConnectedToNetwork() {
            showAlert(title: "No Internet Connection", message: "Can't fetch new photos")
            return
        }
        showLoading(show: true)
        for photo in photos {
            dataController?.viewContext.delete(photo)
        }
        try? dataController?.viewContext.save()
        getNextPage()
        getPhotos()
    }
    
    private func setupFetchedResultsController(completion: @escaping (() -> Void)) {
        guard let dataController = dataController, let pin = pin else { return }
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photoID", ascending: false)
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
    
    private func savePhotosToCoredata(_ photos: [FlickrPhoto]) {
        guard let dataController = dataController else { return }
        photos.forEach { (flickr: FlickrPhoto) in
            let photo = Photo(context: dataController.viewContext)
            photo.data = flickr.thumbnail?.pngData()
            photo.photoID = flickr.photoID
            photo.url = flickr.flickrImageURL()?.absoluteString
            photo.pin = self.pin
        }
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
        showLoading(show: false)
    }
    
    private func getPhotos() {
        if Reachability.isConnectedToNetwork() {
            getFlickerPhotos(page: page) { (photos, error) in
                guard let photos = photos else {
                    debugPrint("Show error message")
                    return
                }
                self.savePhotosToCoredata(photos)
            }
        } else {
            showAlert(title: "You are not connected to the internet!", message: "")
        }
    }
    
    private func getFlickerPhotos(page: Int, completion: @escaping (([FlickrPhoto]?, Error?) -> Void)) {
        guard let location = pin?.location, let lon = pin?.longitude, let lat = pin?.latitude else { return }
        Flickr().searchFlickr(for: location, page: page, lon: lon, lat: lat) { (result: Result<FlickrSearchResults>) in
            switch result {
            case .results(let result):
                completion(result.searchResults, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }
    
    private func getNextPage() {
        if page == 10 {
            page = 1
        } else {
            page += 1
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let photo = fetchedResultsController.fetchedObjects?[indexPath.row]
        
        if let url = photo?.url {
            cell.loadImageBy(url: url)
        } else {
            cell.loadImageBy(data: photo?.data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [indexPath!])
        case .delete:
            collectionView.deleteItems(at:[indexPath!])
        default:
            break
        }
    }
    
    func deletePhoto(at indexPath: IndexPath) {
        let noteToDelete = fetchedResultsController.object(at: indexPath)
        dataController?.viewContext.delete(noteToDelete)
        try? dataController?.viewContext.save()
    }
}
