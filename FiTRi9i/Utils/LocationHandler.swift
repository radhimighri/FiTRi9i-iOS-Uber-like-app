//
//  LocationHandler.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 05/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        
        //set the LocationHandler as the delegate of the locationManager
        locationManager.delegate = self
        
    }
    
    
    // what we want to happen when the authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // so essentially as soon as the user requests or allows the one in use authrization status (.authorizedWhenInUse) we want to immediatly prompt them for the always authorization status without them having to restart the app because what if they don't restart the app for a long time
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
        
    }
}
