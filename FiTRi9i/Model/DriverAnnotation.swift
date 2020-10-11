//
//  DriverAnnotation.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 05/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
   dynamic var coordinate: CLLocationCoordinate2D
    
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}
