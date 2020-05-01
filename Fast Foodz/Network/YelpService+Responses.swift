//
//  YelpService+Responses.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import RealmSwift

extension YelpService {
        /**
            Decoable class that takes care of decoding the search business json
        */
        class SearchBusinessesResponse: Decodable {
            enum ResponseCodingKeys: String, CodingKey {
                case total, businesses, region
            }
        
            enum BusinessCodingKeys: String, CodingKey {
                case categories, coordinates, displayPhone = "display_phone",
                    distance, id, alias, imageUrl = "image_url",
                    isClosed = "is_closed", location, name, phone, price,
                    rating, reviewCount = "review_count", url, transactions
            }
            
            enum CategoryCodingKeys: String, CodingKey {
                case alias, title
            }
    
            enum LocationCodingKeys: String, CodingKey {
                case city, country, address1, address2, address3, state,
                    zipCode = "zip_code", displayAddress = "display_address"
            }
    
            enum RegionCodingKeys: String, CodingKey {
                case center
            }
    
            enum CoordinateCodingKeys: String, CodingKey {
                case latitude, longitude
            }
    
            struct Region {
                let center: Coordinate?
            }
    
            let total: Int?
            let businesses: [Business]?
            let regionCenter: Coordinate?
    
            required init(from decoder: Decoder) throws {
                let responseValues = try decoder.container(keyedBy: ResponseCodingKeys.self)
                    
                self.total = try? responseValues.decodeIfPresent(Int.self, forKey: ResponseCodingKeys.total)
                self.businesses = SearchBusinessesResponse.decodeBusinesses(from: responseValues)
                self.regionCenter = SearchBusinessesResponse.decodeRegionCenter(from: responseValues)
            }
    
            static private func decodeBusinesses(from: KeyedDecodingContainer<ResponseCodingKeys>) -> [Business]? {
                guard var container = try? from.nestedUnkeyedContainer(forKey: .businesses) else {
                    return nil
                }
    
                var retArray = [Business]()
    
                while !container.isAtEnd {
                    guard let businessValues = try? container.nestedContainer(keyedBy: BusinessCodingKeys.self) else {
                        continue
                    }
                    
                    let business = Business()
                    
                    business.categories.append(objectsIn: decodeCategories(from: businessValues))
                    business.coordinates = decodeCoordinates(from: businessValues)
                    business.displayPhone = try? businessValues.decodeIfPresent(String.self, forKey: .displayPhone)
                    business.distance.value = try? businessValues.decodeIfPresent(Double.self, forKey: .distance)
                    business.id = try? businessValues.decodeIfPresent(String.self, forKey: .id)
                    business.alias = try? businessValues.decodeIfPresent(String.self, forKey: .alias)
                    business.imageUrl = try? businessValues.decodeIfPresent(String.self, forKey: .imageUrl)
                    business.isClosed.value = try? businessValues.decodeIfPresent(Bool.self, forKey: .isClosed)
                    business.location = decodeLocation(from: businessValues)
                    business.name = try? businessValues.decodeIfPresent(String.self, forKey: .name)
                    business.phone = try? businessValues.decodeIfPresent(String.self,forKey: .phone)
                    business.price = try? businessValues.decodeIfPresent(String.self, forKey: .price)
                    business.rating.value = try? businessValues.decodeIfPresent(Double.self, forKey: .rating)
                    business.reviewCount.value = try? businessValues.decodeIfPresent(Int.self, forKey: .reviewCount)
                    business.url = try? businessValues.decodeIfPresent(String.self, forKey: .url)
                    
                    if let tTransactions = try? businessValues.decodeIfPresent([String].self, forKey: .transactions) {
                        business.transactions.append(objectsIn: tTransactions)
                    }
                    
                    retArray.append(business)
                }
                
                return retArray.isEmpty ? nil : retArray
            }
            
            static private func decodeCategories(from: KeyedDecodingContainer<BusinessCodingKeys>) -> List<Category> {
                let retList = List<Category>()

                guard var container = try? from.nestedUnkeyedContainer(forKey: .categories) else {
                    return retList
                }
                
                while !container.isAtEnd {
                    guard let categoryValues = try? container.nestedContainer(keyedBy: CategoryCodingKeys.self) else {
                        continue
                    }
                    
                    let category = Category()
                    
                    category.alias = try? categoryValues.decodeIfPresent(String.self, forKey: .alias)
                    category.title = try? categoryValues.decodeIfPresent(String.self, forKey: .title)
                    
                    retList.append(category)
                }
                                
                return retList
            }
            
            static private func decodeCoordinates(from: KeyedDecodingContainer<BusinessCodingKeys>) -> Coordinate? {
                guard let container = try? from.nestedContainer(keyedBy: CoordinateCodingKeys.self, forKey: .coordinates) else { return nil }
                
                let coordinate = Coordinate()
                
                coordinate.latitude.value = try? container.decodeIfPresent(Double.self, forKey: .latitude)
                coordinate.longitude.value = try? container.decodeIfPresent(Double.self, forKey: .longitude)
                
                return (coordinate.latitude.value != nil && coordinate.longitude.value != nil) ? coordinate : nil
            }
            
            static private func decodeLocation(from: KeyedDecodingContainer<BusinessCodingKeys>) -> Location? {
                guard let container = try? from.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location) else { return nil }
                
                let location = Location()
                
                location.address1 = try? container.decodeIfPresent(String.self, forKey: .address1)
                location.address2 = try? container.decodeIfPresent(String.self, forKey: .address2)
                location.address3 = try? container.decodeIfPresent(String.self, forKey: .address3)
                location.city = try? container.decodeIfPresent(String.self, forKey: .city)
                location.country = try? container.decodeIfPresent(String.self, forKey: .country)
                if let tDisplayAddress = try? container.decodeIfPresent([String].self, forKey: .displayAddress) {
                    location.displayAddress.append(objectsIn: tDisplayAddress)
                }
                location.state = try? container.decodeIfPresent(String.self, forKey: .state)
                location.zipCode = try? container.decodeIfPresent(String.self, forKey: .zipCode)
                
                return location
            }
            
            static private func decodeRegionCenter(from: KeyedDecodingContainer<ResponseCodingKeys>) -> Coordinate? {
                guard let container = try? from.nestedContainer(keyedBy: RegionCodingKeys.self, forKey: .region) else {
                    return nil
                }
                
                guard let regionCenterContainer = try? container.nestedContainer(keyedBy: CoordinateCodingKeys.self, forKey: .center) else {
                    return nil
                }
                
                let coordinate = Coordinate()
                    
                coordinate.latitude.value = try? regionCenterContainer.decodeIfPresent(Double.self, forKey: .latitude)
                coordinate.longitude.value = try? regionCenterContainer.decodeIfPresent(Double.self, forKey: .longitude)
                       
                let isValid = (coordinate.latitude.value != nil && coordinate.longitude.value != nil)
                
                return (isValid) ? coordinate : nil
            }
        }
    
}
