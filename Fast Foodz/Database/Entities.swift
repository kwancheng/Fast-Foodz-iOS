//
//  Entities.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import Foundation
import RealmSwift
import MapKit

class SearchResponse: Object {
    @objc dynamic var requestDate: Date?
    let businesses = RealmSwift.List<Business>()
    @objc dynamic var regionCenter: Coordinate?
}

class Business: Object {
    let categories = RealmSwift.List<Category>()
    @objc dynamic var coordinates: Coordinate?
    @objc dynamic var displayPhone: String?
    let distance = RealmOptional<Double>()
    @objc dynamic var id: String?
    @objc dynamic var alias: String?
    @objc dynamic var imageUrl: String?
    let isClosed = RealmOptional<Bool>()
    @objc dynamic var location: Location?
    @objc dynamic var name: String?
    @objc dynamic var phone: String?
    @objc dynamic var price: String?
    let rating = RealmOptional<Double>()
    let reviewCount = RealmOptional<Int>()
    @objc dynamic var url: String?
    let transactions = RealmSwift.List<String>()
}

class Category: Object {
    @objc dynamic var alias: String?
    @objc dynamic var title: String?
}

class Coordinate: Object {
    let latitude = RealmOptional<Double>()
    let longitude = RealmOptional<Double>()
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D? {
        guard let lat = latitude.value,
            let lon = longitude.value else { return nil }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

class Location: Object {
    @objc dynamic var address1: String?
    @objc dynamic var address2: String?
    @objc dynamic var address3: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    let displayAddress = RealmSwift.List<String>()
    @objc dynamic var state: String?
    @objc dynamic var zipCode: String?
}
