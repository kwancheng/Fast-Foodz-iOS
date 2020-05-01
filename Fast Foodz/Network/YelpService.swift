//
//  Service.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import Foundation
import Alamofire
import RealmSwift

class YelpService {
    static private var headers: HTTPHeaders = {
        var headers = HTTPHeaders()
        headers["Authorization"] = "Bearer \(YELP_API_KEY)"
        return headers
    }()
    
    /**
     https://www.yelp.com/developers/documentation/v3/business_search
     @param radiusMeters search area, max 40000
     @param limit number of businesses to return default: 20 max: 50
     */
    static func searchBusinesses(
        location: LocationParam,
        term: String? = nil,
        radiusMeters: Int? = nil,
        categories: [String]? = nil,
        locale: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        sortBy: SortByParam? = nil,
        price: [PriceFilter]? = nil,
        openNow: Bool? = nil,
        openAt: Int? = nil, // unix time
        attributes: [BusinessAttributes]? = nil,
        completion:  ((Swift.Result<SearchBusinessesResponse, Error>) -> Void)?
    ) {
        let builder = ParamsBuilder()
            .appendIfNotNil(key: "term", value: term)
            .appendFromHandler({ (builder) in
                if let locationStr = location.location {
                    builder.appendIfNotNil(key: "location", value: locationStr)
                } else {
                    builder.appendIfNotNil(key: "latitude", value: location.latitude)
                    builder.appendIfNotNil(key: "longitude", value: location.longitude)
                }
            })
            .appendIfNotNil(key: "radius", value: radiusMeters)
            .appendIfNotNil(key: "categories", value: categories)
            .appendIfNotNil(key: "locale", value: locale)
            .appendIfNotNil(key: "limit", value: limit)
            .appendIfNotNil(key: "offset", value: offset)
            .appendIfNotNil(key: "sort_by", value: sortBy?.rawValue)
            .appendIfNotNil(key: "price", value: price)
            .appendIfNotNil(key: "open_now", value: openNow)
            .appendIfNotNil(key: "attributes", fromHandler: { (builder) ->  Any? in
                return attributes?.map({"\($0.rawValue)"})
            })
        
        let url = YELP_BASE_URL.appending("/v3/businesses/search")
        
        Alamofire
            .request(url, method: .get, parameters: builder.params,
                     encoding: CustomUrlEncoding(), headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let sbResponse = try decoder.decode(SearchBusinessesResponse.self, from: data)
                        completion?(.success(sbResponse))
                    } catch {
                        completion?(.failure(error))
                    }

                case.failure(let error):
                    completion?(.failure(error))
                }
            }
    }
}
