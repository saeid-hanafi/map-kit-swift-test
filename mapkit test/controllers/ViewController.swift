//
//  ViewController.swift
//  mapkit test
//
//  Created by Macvps on 5/8/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    private let mapKitView = MKMapView()
    private let locationManager = CLLocationManager()
    
    /**
     Initialize Stored Properties And Map View
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapKitView.delegate = self
        self.locationManager.delegate = self
        
        mapKitView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(mapKitView)
    }
    
    /**
     Use Functions After View Did Appear
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goToUserLocation()
        if let location = locationManager.location?.coordinate {
            let locDes = CLLocationCoordinate2D(latitude: 37.7749, longitude: 122.4194)
//            self.drawDirectionOnMobileMap(loc1: location, loc2: locDes)
            self.drawDirectionOnAppMap(loc1: location, loc2: locDes)
        }
//        goToLoc(34.0522, 118.2437, latSpan: 0.2, longSpan: 0.2)
//        addPin(34.0552, 118.2437, title: "Los Angeles", subTitle: "A City Of USA")
    }

    /**
     Go To The Specific Location
     */
    private func goToLoc(_ lat: Double, _ long: Double, latSpan: CLLocationDegrees, longSpan: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: longSpan)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapKitView.setRegion(region, animated: true)
    }
    
    /**
     Add Pin On Specific Location
     */
    private func addPin(_ lat: Double, _ long: Double, title: String, subTitle: String) {
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        pin.title = title
        pin.subtitle = subTitle
        self.mapKitView.addAnnotation(pin)
    }
    
    /**
     Go To Current User Location
     */
    private func goToUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.mapKitView.showsUserLocation = true
            
            if let location = self.locationManager.location?.coordinate {
                let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                let region = MKCoordinateRegion(center: location, span: span)
                self.mapKitView.setRegion(region, animated: true)
            }
        }
    }
    
    /**
     Draw Direction Between Two Location By Open Mobile Map
     */
    private func drawDirectionOnMobileMap(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) {
        let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
        source.name = "Source Address"
        
        let des = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
        des.name = "Destination Address"
        
        MKMapItem.openMaps(with: [source, des], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    /**
     Draw Direction Between Two Location By App Map
     */
    private func drawDirectionOnAppMap(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: loc1)
        let desPlaceMark = MKPlacemark(coordinate: loc2)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let desMapItem = MKMapItem(placemark: desPlaceMark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Source"
        sourceAnnotation.coordinate = loc1
        
        let desAnnotation = MKPointAnnotation()
        desAnnotation.title = "Destination"
        desAnnotation.coordinate = loc2
        
        self.mapKitView.showAnnotations([sourceAnnotation, desAnnotation], animated: true)
        
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = desMapItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { resp, error in
            guard let response = resp else {
                print("Error is : \(error?.localizedDescription)")
                return
            }
            
            let route = response.routes[0]
            let rect = route.polyline.boundingMapRect
            
            self.mapKitView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            self.mapKitView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

extension ViewController {
    /**
     Customize Map Direction View On App Map
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 4
        
        return renderer
    }
}
