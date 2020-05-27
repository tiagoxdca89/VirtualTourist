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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapKit()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier,
            let photoAlbum = segue.destination as? PhotoAlbumViewController else { return }
        guard let location = sender as? String else { return }
        photoAlbum.location = location
    }
    

    private func setupMapKit() {
        mapManager = MapKitManager(map: mapKit)
        mapManager?.delegate = self
        guard let manager = mapManager else { return }
        mapKit.delegate = manager
    }
}

extension TravelLocationsViewController: MapKitManagerDelegate {
    func tapOnLocation(location: String) {
        self.performSegue(withIdentifier: segueIdentifier, sender: location)
    }
}
