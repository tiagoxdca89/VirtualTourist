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
    
    var mapManager: MapKitManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapKit()
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
        print("=====Tap on \(location)")
    }
}
