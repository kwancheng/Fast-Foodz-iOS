//
//  Database.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import Foundation
import RealmSwift

class Database {
    static let shared: Database = {
        return Database()
    }()
    
    private let opQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "Database Operation Queue"
        return q
    }()
    
    private init() {}
    
    func refreshBusinesses(latitude: Double, longitude: Double, radiusMeters: Int, completion: ((Bool) -> Void)?) {
        opQueue.addOperation {
            let location = YelpService.LocationParam(latitude: latitude, longitude: longitude)
            let categories = ["pizza", "mexican", "chinese", "burgers"]
            YelpService.searchBusinesses( location: location, radiusMeters: radiusMeters,
                                          categories: categories, sortBy: .distance,
                completion: { result in
                    var refreshed = false
                    switch result {
                    case .success(let response):
                        do {
                            let realm = try Realm()
                            try realm.write {
                                if let regionCenter = response.regionCenter,
                                    let businesses = response.businesses
                                {
                                    let searchResponse = SearchResponse()
                                    searchResponse.requestDate = Date()
                                    searchResponse.regionCenter = regionCenter
                                    searchResponse.businesses.append(objectsIn: businesses)
                                    realm.add(searchResponse)
                                }
                                refreshed = true
                            }
                        } catch {
                        }

                    case .failure(_):
                        break
                    }
                    
                    DispatchQueue.main.async {
                        completion?(refreshed)
                    }
                })
        }
    }
}
