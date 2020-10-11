//
//  Trip.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 07/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import CoreLocation

// Its a best practice to use an enumeration as opposed to using multiple Boolean variables

enum TripState: Int {
    case requested //0
    case denied //1
    case accepted //2
    case driverArrived //3
    case inProgress //4
    case arrivedAtDestination //5
    case completed //6
}


struct Trip {
    
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengerUid: String!
    var driverUid: String?
    var state: TripState!
    
    // the passengerUid will not be in the dictionary values, it represents the snapshot key, every passengerUid will have its dictionary
    init(passengerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else {return}
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else {return}
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else {return}
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else {return}
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
    
}

