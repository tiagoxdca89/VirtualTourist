//
//  MapKitManager.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 27/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import Foundation
import MapKit

class MapKitManager {
    
    let map: MKMapView
    var pins: [PinModel] = []
    
    init(map: MKMapView) {
        self.map = map
    }
    
    private func addLongPressGestureToMap() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gesture.minimumPressDuration = 2.0
        map.addGestureRecognizer(gesture)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: map)
            let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates

            let location = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if let error = error {
                    return
                }
                
            guard let placemarks = placemarks else { return }

            if placemarks.count > 0 {
                let pm = placemarks[0]

                annotation.title = pm.locality
                annotation.subtitle = pm.subLocality
                self.map.addAnnotation(annotation)
                debugPrint("[Locality] => \(pm.locality ?? "Unknown")")
            }
            else {
                annotation.title = "Unknown Place"
                self.map.addAnnotation(annotation)
            }
                self.pins.append(PinModel(locationName: annotation.title, latitude: newCoordinates.latitude, longitude: newCoordinates.longitude))
        })
    }
    }
}
