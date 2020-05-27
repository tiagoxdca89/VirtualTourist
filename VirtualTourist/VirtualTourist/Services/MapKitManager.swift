//
//  MapKitManager.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 27/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import Foundation
import MapKit

typealias MKLocation = (name: String, coordinate: CLLocationCoordinate2D)

protocol MapKitManagerDelegate: class {
    func tapOnLocation(location: MKLocation)
}

class MapKitManager: NSObject {
    
    let map: MKMapView
    static var pins: [PinModel] = []
    weak var delegate: MapKitManagerDelegate?
    
    init(map: MKMapView) {
        self.map = map
        super.init()
        self.addLongPressGestureToMap()
    }
    
    private func addLongPressGestureToMap() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        gesture.minimumPressDuration = 1.0
        map.addGestureRecognizer(gesture)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == .began{
            
            let coordinates = getCoordinates(gestureRecognizer)
            let annotation = makeAnnotation(coordinates)
            let location = getLocation(coordinates)
            reverseGeocodeLocation(location, annotation, coordinates)
        }
    }
}

extension MapKitManager{
    private func getCoordinates(_ gestureRecognizer: UIGestureRecognizer) -> CLLocationCoordinate2D {
        let touchPoint = gestureRecognizer.location(in: map)
        return map.convert(touchPoint, toCoordinateFrom: map)
    }
    
    private func makeAnnotation(_ coordinates: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        return annotation
    }
    
    private func getLocation(_ coordinates: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    private func insertAnnotationOnMap(_ placemarks: [CLPlacemark], annotation: MKPointAnnotation) {
        if placemarks.count > 0 {
            let pm = placemarks[0]
            
            annotation.title = pm.locality
            annotation.subtitle = pm.subLocality
            self.map.addAnnotation(annotation)
            debugPrint("[Locality] => \(pm.locality ?? pm.subLocality ?? "Unknown Place")")
        }
        else {
            annotation.title = "Unknown Place"
            self.map.addAnnotation(annotation)
        }
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation, _ annotation: MKPointAnnotation, _ coordinates: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                debugPrint("\(error.localizedDescription)")
                return
            }
            guard let placemarks = placemarks else { return }
            self.insertAnnotationOnMap(placemarks, annotation: annotation)
            MapKitManager.pins.append(PinModel(locationName: annotation.title, latitude: coordinates.latitude, longitude: coordinates.longitude))
        })
    }
}
extension MapKitManager: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let title = view.annotation?.title, let subtitle = view.annotation?.subtitle else {
                print("Something went wrong")
                return
            }
            guard let coordinate = view.annotation?.coordinate else { return }
            delegate?.tapOnLocation(location: (name: title ?? subtitle ?? "Unknown",
                                               coordinate: coordinate))
        }
    }
}
