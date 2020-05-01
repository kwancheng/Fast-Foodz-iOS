//
//  BusinessAnnotation.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/23/20.
//

import UIKit
import MapKit

class BusinessAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        guard
            !business.isInvalidated,
            let lat = business.coordinates?.latitude.value,
            let long = business.coordinates?.longitude.value
        else {
            return CLLocationCoordinate2D()
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }

    let business: Business
    
    init(business: Business) {
        self.business = business
    }
}
