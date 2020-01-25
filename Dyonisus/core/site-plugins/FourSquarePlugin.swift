//
//  FourSquarePlugin.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/24/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import CoreLocation

class FourSquarePlugin: SitePlugin {
    
    var name = "FourSquare"
    var logo = "4sq-icon"
    var totalScore = 10
    
    let baseUrl = "https://api.foursquare.com/v2/venues/"
    let authParams = "&client_id=\(FOURSQUARE_CLIENT_ID)" +
        "&client_secret=\(FOURSQUARE_CLIENT_SECRET)&v=\(FOURSQUARE_VERSION)"
    
    func searchForPlaces(
        with name: String,
        location: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (SitePlugin) -> Void) {
        let url = baseUrl + "search?near=\(location)&query=\(name)" + authParams
        _searchForPlaces(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func searchForPlaces(
        with name: String,
        coordinate: CLLocationCoordinate2D,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (SitePlugin) -> Void) {
        let url = baseUrl + "search?ll=\(coordinate.latitude),\(coordinate.longitude)&query=\(name)" + authParams
        _searchForPlaces(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func _searchForPlaces(
        with url: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (SitePlugin) -> Void) {
        loadUrl(
            urlString: url,
            authentication: nil,
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let response = json["response"] as? [String: Any],
                    let venues = response["venues"] as? [[String: Any]] {
                    successCallbackFunc(self._parseSearchResultToModels(venues: venues), self)
                } else {
                    errorCallbackFunc(self)
                }
            },
            onError: { errorCallbackFunc(self)}
        )
    }
    
    func loadRatingAndDetails(
        for place: PlaceInfoModel,
        successCallbackFunc: @escaping (PlaceInfoModel, SitePlugin) -> Void,
        errorCallbackFunc: @escaping (SitePlugin) -> Void) {
        let url = baseUrl + "\(place.place_id)?" + authParams
        loadUrl(
            urlString: url,
            authentication: nil,
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let response = json["response"] as? [String: Any],
                    let venue = response["venue"] as? [String: Any],
                    let model = self._parseDetailsResultToModel(venue: venue) {
                    successCallbackFunc(model, self)
                } else {
                    errorCallbackFunc(self)
                }
            },
            onError: { errorCallbackFunc(self)}
        )
    }
    
    func _parseSearchResultToModels(venues: [[String: Any]]) -> [PlaceInfoModel] {
        return venues.map { (venue: [String: Any]) -> PlaceInfoModel? in
            guard let place_id = venue["id"] as? String,
                let name = venue["name"] as? String,
                let location = venue["location"] as? [String: Any],
                let lon = location["lng"] as? Double,
                let lat = location["lat"] as? Double,
                let addr = location["formattedAddress"] as? [String] else {
                    print("fails to denormalize")
                    return nil
            }
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: addr.joined(separator: ", "),
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
            )
        }.compactMap{ $0}
    }
    
    func _parseDetailsResultToModel(venue: [String: Any]) -> PlaceInfoModel? {
        guard let place_id = venue["id"] as? String,
            let name = venue["name"] as? String,
            let location = venue["location"] as? [String: Any],
            let lon = location["lng"] as? Double,
            let lat = location["lat"] as? Double,
            let addr = location["formattedAddress"] as? [String],
            let url = venue["canonicalUrl"] as? String,
            let score = venue["rating"] as? Double,
            let numOfScores = venue["ratingSignals"] as? Int else {
                print("fails to denormalize")
                return nil
        }
        let price = venue["price"] as? [String: Any]
        let hours = venue["hours"] as? [String: Any]
        let categoryList = venue["categories"] as? [[String: Any]]
        var imageUrl : String?
        if let bestPhoto = venue["bestPhoto"] as? [String: Any],
            let prefix = bestPhoto["prefix"] as? String,
            let suffix = bestPhoto["suffix"] as? String {
            imageUrl = "\(prefix)height\(PHOTO_HEIGHT)\(suffix)"
        }
        return PlaceInfoModel(
            place_id: place_id,
            name: name,
            formattedAddress: addr.joined(separator: ", "),
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            score: score,
            numOfScores: numOfScores,
            url: url,
            price: price?["tier"] as? Int ?? 0,
            imageUrl: imageUrl,
            categories: categoryList?.map{ $0["name"] as? String }.compactMap{ $0},
            hours: hours?["status"] as? String,
            open_now: hours?["isOpen"] as? Bool
        )
    }
}
