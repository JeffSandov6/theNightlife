//
//  Location_Manager.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import GooglePlaces



extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let location: CLLocation = locations.last!
    //        print("Location: \(location)")
    //
    //        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
    //                                              longitude: location.coordinate.longitude,
    //                                              zoom: zoomLevel)
    //
    //        if mapView.isHidden {
    //            mapView.isHidden = false
    //            mapView.camera = camera
    //        } else {
    //            mapView.animate(to: camera)
    //        }
    //
    //        //listLikelyPlaces()
    //    }
    //
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    
}

