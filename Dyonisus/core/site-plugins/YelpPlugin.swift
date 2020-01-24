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
    
    var name = "Yelp"
    var logo = "yelp-icon"
    var totalScore = 5
    
    let baseUrl = "https://api.yelp.com/v3/businesses/search?"
    
    func searchForPlaces(
        with name: String,
        location: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (SitePlugin) -> Void
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
        errorCallbackFunc: @escaping (SitePlugin) -> Void
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
        errorCallbackFunc: @escaping (SitePlugin) -> Void) {
        successCallbackFunc(place, self)
    }
    
    func _searchForPlacesHelper(
        with url: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (SitePlugin) -> Void
    ) {
        let completionHandler = { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if let error = error {
                logMessage("Error when searching with Yelp: \(error)")
                errorCallbackFunc(self)
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if httpResponse == nil || (200...299).contains(httpResponse!.statusCode) == false {
                logMessage("Error when searching with Yelp" +
                    (httpResponse == nil ? "" : ": status code = \(httpResponse!.statusCode)"))
                errorCallbackFunc(self)
                return
            }
            if let mimeType = httpResponse!.mimeType, mimeType == "application/json",
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []){
                let models = self._parseJsonToModels(json: json as! [String: Any])
                successCallbackFunc(models, self)
            }
        }
        loadUrl(urlString: url, authentication: "Bearer \(YELP_API_KEY)", completionHandler: completionHandler)
    }
    
    func _parseJsonToModels(json: [String: Any]) -> [PlaceInfoModel] {
        let businesses = json["businesses"] as! [[String: Any]]
        
        return businesses.map { (biz: [String: Any]) -> PlaceInfoModel? in
            guard let place_id = biz["id"] as? String,
                let name = biz["name"] as? String,
                let location = biz["location"] as? [String: Any],
                let coordinate = biz["coordinate"] as? [String: Double],
                let lon = coordinate["longtitude"],
                let lat = coordinate["latitude"],
                let addr = location["display_address"] as? [String],
                let score = biz["rating"] as? Double,
                let num = biz["review_count"] as? Int,
                let priceStr = biz["price"] as? String else {
                    print("fails to denormalize")
                    return nil
            }
            let categories = biz["categories"] as? [[String: String?]] ?? [[String: String?]]()
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: addr.joined(separator: ", "),
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                score: score,
                numOfScores: num,
                url: biz["url"] as? String,
                price: priceStr.count,
                
                imageUrl: biz["image_url"] as? String,
                categories: categories.map{ $0["title"] as? String }.compactMap{$0},
                phone: biz["display_phone"] as? String,
                permanently_closed: biz["is_closed"] as? Bool
            )
        }.compactMap{ $0}
    }
}

