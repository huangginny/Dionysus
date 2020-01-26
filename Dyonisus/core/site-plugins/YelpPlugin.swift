//
//  YelpPlugin.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/21/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import CoreLocation

class YelpPlugin : SitePlugin {
    
    var name: String
    var logo: String
    var totalScore: Int
    
    let baseUrl = "https://api.yelp.com/v3/businesses/search?"
    
    required init() {
        name = "Yelp"
        logo = "yelp-icon"
        totalScore = 5
    }
    
    func searchForPlaces(
        with name: String,
        location: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        let urlString = baseUrl + "&term=\(name)&location=\(location)"
        self._searchForPlacesHelper(
            with: urlString,
            successCallbackFunc: successCallbackFunc,
            errorCallbackFunc: errorCallbackFunc
        )
    }
    
    func searchForPlaces(
        with name: String,
        coordinate: CLLocationCoordinate2D,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        let urlString = baseUrl + "&term=\(name)&latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)"
        self._searchForPlacesHelper(
            with: urlString,
            successCallbackFunc: successCallbackFunc,
            errorCallbackFunc: errorCallbackFunc
        )
    }
    
    func loadRatingAndDetails(
        for place: PlaceInfoModel,
        successCallbackFunc: @escaping (PlaceInfoModel, SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        successCallbackFunc(place, self)
    }
    
    func _searchForPlacesHelper(
        with url: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        loadUrl(
            urlString: url,
            authentication: "Bearer \(YELP_API_KEY)",
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let businesses = json["businesses"] as? [[String: Any]]{
                    let models = self._parseJsonToModels(jsonList: businesses)
                    successCallbackFunc(models, self)
                } else {
                    errorCallbackFunc("An error occurred when retrieving places from Yelp.", self) // fixme
                }
            },
            onError: {(errorMsg: String) -> Void in errorCallbackFunc(errorMsg, self)}
        )
    }
    
    func _parseJsonToModels(jsonList: [[String: Any]]) -> [PlaceInfoModel] {
        return jsonList.map { (biz: [String: Any]) -> PlaceInfoModel? in
            guard let place_id = biz["id"] as? String,
                let name = biz["name"] as? String,
                let location = biz["location"] as? [String: Any],
                let coordinate = biz["coordinates"] as? [String: Double],
                let lon = coordinate["longitude"],
                let lat = coordinate["latitude"],
                let addr = location["display_address"] as? [String],
                let score = biz["rating"] as? Double,
                let num = biz["review_count"] as? Int else {
                    logMessage("Fails to denormalize basic information")
                    return nil
            }
            let categoryList = biz["categories"] as? [[String: String?]] ?? [[String: String?]]()
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: addr,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                score: score,
                numOfScores: num,
                url: biz["url"] as? String,
                price: (biz["price"] as? String)?.count ?? 0,
                
                imageUrl: biz["image_url"] as? String,
                categories: categoryList.map{ $0["title"] as? String }.compactMap{$0},
                phone: biz["display_phone"] as? String,
                permanently_closed: biz["is_closed"] as? Bool
            )
        }.compactMap{ $0}
    }
}

