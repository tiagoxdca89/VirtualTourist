//
//  MapKitManager.swift
//  VirtualTourist
//
//  Created by Tiago Xavier da Cunha Almeida on 27/05/2020.
//  Copyright © 2020 Tiago Xavier da Cunha Almeida. All rights reserved.
//

import Foundation
import MapKit
import CoreData


protocol MapKitManagerDelegate: class {
    func tapOnLocation(pin: Pin)
}

class MapKitManager: NSObject {
    
    let map: MKMapView
    let dataController: DataController
    var pins: [Pin] = []
    weak var delegate: MapKitManagerDelegate?
    
    init(map: MKMapView, dataController: DataController) {
        self.map = map
        self.dataController = dataController
        super.init()
        self.addTapGestureToMap()
        fetchPins()
    }
    
    private func fetchPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "location", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            addAnnotationsToMap(pins: pins)
        }
    }
    
    private func addTapGestureToMap() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        gesture.delegate = self
        map.addGestureRecognizer(gesture)
    }
    
    private func addPanGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        gesture.minimumPressDuration = 1
        gesture.delegate = self
        map.addGestureRecognizer(gesture)
    }
    
    @objc func addAnnotation(gesture: UIGestureRecognizer){
        if gesture.state == .ended {
            let coordinates = getCoordinates(gesture)
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
    
    private func addAnnotationToMap(_ placemarks: [CLPlacemark], annotation: MKPointAnnotation) {
        if placemarks.count > 0 {
            let pm = placemarks[0]
            annotation.title = pm.locality
            annotation.subtitle = pm.subLocality
            self.map.addAnnotation(annotation)
        }
    }
    
    private func addAnnotationsToMap(pins: [Pin]) {
        var annotations: [MKAnnotation] = []
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = pin.location
            annotations.append(annotation)
        }
        self.map.addAnnotations(annotations)
    }
    
    private func savePin(_ annotation: MKPointAnnotation, coordinates: CLLocationCoordinate2D) {
        let pin = Pin(context: self.dataController.viewContext)
        pin.location = annotation.title
        pin.longitude = coordinates.longitude as Double
        pin.latitude = coordinates.latitude as Double
        if dataController.viewContext.hasChanges {
            try? self.dataController.viewContext.save()
        }
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation, _ annotation: MKPointAnnotation, _ coordinates: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                debugPrint("\(error.localizedDescription)")
                return
            }
            guard let placemarks = placemarks else { return }
            self.addAnnotationToMap(placemarks, annotation: annotation)
            self.savePin(annotation, coordinates: coordinates)
        })
    }
    
    private func fetchPinBy(location: String?, coordinates: CLLocationCoordinate2D?) -> Pin? {
        guard let location = location, let coordinates = coordinates else { return nil }
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "latitude == %lf && location == %@", coordinates.latitude, location)
        fetchRequest.predicate = predicate
        return try? dataController.viewContext.fetch(fetchRequest).first
        
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
            if let pin = fetchPinBy(location: view.annotation?.title ?? nil, coordinates: view.annotation?.coordinate) {
                delegate?.tapOnLocation(pin: pin)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        DispatchQueue.main.async {
            mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: false) }
        }
    }
}

extension MapKitManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if map.annotations.count == 0 {
            return true
        }
        return map.annotations.count > 0 && touch.view?.frame.height ?? 0 > 100
    }
}
