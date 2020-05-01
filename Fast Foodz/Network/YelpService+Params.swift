//
//  YelpServiceParams.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import Foundation

extension YelpService { // poorman namespacing
    // MARK: Parameters
    
    /** Yelp businesses search api requires either the location term or the lat,long of the search area. see docs for details.*/
    struct LocationParam {
        let location: String?
        let latitude: Double?
        let longitude: Double?
        
        init(location: String) {
            self.location = location
            self.latitude = nil
            self.longitude = nil
        }
        
        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
            self.location = nil
        }
    }
    
    enum SortByParam: String {
        case bestMatch = "best_match",
        rating = "rating",
        reviewCount = "review_count",
        distance = "distance"
    }
    
    enum PriceFilter: Int {
        case price1, price2, price3, price4 // $, $$, $$$, $$$$ respectively
    }
    
    enum BusinessAttributes: String {
        case hotAndNew = "hot_and_new",
        request_a_quote = "request_a_quote",
        reservation = "reservation",
        waitlistReservation = "waitlistReservation",
        cashback = "cashback",
        deals = "deals",
        genderNeutralRestrooms = "gender_neutral_restrooms",
        openToAll = "open_to_all",
        wheelchairAccessible = "wheelchair_accessible"
    }
}
