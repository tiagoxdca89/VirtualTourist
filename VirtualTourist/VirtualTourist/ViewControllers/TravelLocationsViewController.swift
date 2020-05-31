//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 26/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController {
    
    
    @IBOutlet weak var mapKit: MKMapView!
    
    let segueIdentifier = "toPhotoAlbum"
    var mapManager: MapKitManager?
    let dataController = DataController(modelName: "VirtualTourist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.load()
        setupMapKit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissCallOut()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier,
            let photoAlbum = segue.destination as? PhotoAlbumViewController else { return }
        guard let pin = sender as? Pin else { return }
        photoAlbum.pin = pin
        photoAlbum.dataController = dataController
    }
    

    private func setupMapKit() {
        mapManager = MapKitManager(map: mapKit, dataController: dataController)
        mapManager?.delegate = self
        guard let manager = mapManager else { return }
        mapKit.delegate = manager
    }
    
    private func dismissCallOut() {
        for annotation in mapKit.selectedAnnotations {
            mapKit.deselectAnnotation(annotation, animated: false)
        }
    }
    
    
    
}

extension TravelLocationsViewController: MapKitManagerDelegate {
    func tapOnLocation(pin: Pin) {
        self.performSegue(withIdentifier: segueIdentifier, sender: pin)
    }
}
