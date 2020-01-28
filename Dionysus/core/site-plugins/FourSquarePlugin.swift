//
//  FourSquarePlugin.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/24/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class FourSquarePlugin: SitePlugin {
    
    var name: String
    var logo: String
    var totalScore: Int
    
    let baseUrl = "https://api.foursquare.com/v2/venues/"
    let authParams = "&client_id=\(FOURSQUARE_CLIENT_ID)" +
        "&client_secret=\(FOURSQUARE_CLIENT_SECRET)&v=\(FOURSQUARE_VERSION)"
    
    required init() {
        name = "FourSquare"
        logo = "4sq-logo"
        totalScore = 10
    }
    
    func searchForPlaces(
        with name: String,
        location: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        let url = baseUrl + "search?near=\(location)&query=\(name)" + authParams
        _searchForPlaces(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func searchForPlaces(
        with name: String,
        coordinate: CLLocationCoordinate2D,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        let url = baseUrl + "search?ll=\(coordinate.latitude),\(coordinate.longitude)&query=\(name)" + authParams
        _searchForPlaces(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func _searchForPlaces( // FIXME: add categories
        with url: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        loadUrl(
            urlString: url,
            authentication: nil,
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let response = json["response"] as? [String: Any],
                    let venues = response["venues"] as? [[String: Any]] {
                    successCallbackFunc(self._parseSearchResultToModels(venues: venues), self)
                } else {
                    errorCallbackFunc("An error occurred when retrieving places from FourSquare.", self)
                }
            },
            onError: {(errorMsg: String) -> Void in errorCallbackFunc(errorMsg, self)}
        )
    }
    
    func loadRatingAndDetails(
        for place: PlaceInfoModel,
        successCallbackFunc: @escaping (PlaceInfoModel, SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        let url = baseUrl + "\(place.place_id)?" + authParams
        loadUrl(
            urlString: url,
            authentication: nil,
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let response = json["response"] as? [String: Any],
                    let venue = response["venue"] as? [String: Any] {
                    let (model, errorMsg) = self._parseDetailsResultToModel(venue: venue)
                    if isNonEmptyString(errorMsg) {
                        errorCallbackFunc(errorMsg, self)
                    } else {
                        successCallbackFunc(model!, self)
                    }
                } else {
                    errorCallbackFunc("An error occurred when retrieving information about this place.", self)
                }
            },
            onError: {(errorMsg: String) -> Void in errorCallbackFunc(errorMsg, self)}
        )
    }
    
    func _parseSearchResultToModels(venues: [[String: Any]]) -> [PlaceInfoModel] {
        return venues.map { (venue: [String: Any]) -> PlaceInfoModel? in
            guard let place_id = venue["id"] as? String,
                let name = venue["name"] as? String,
                let location = venue["location"] as? [String: Any],
                let lon = location["lng"] as? Double,
                let lat = location["lat"] as? Double,
                let addr = location["formattedAddress"] as? [String],
                let postalCode = location["postalCode"] as? String else {
                    logMessage("Fails to denormalize")
                    return nil
            }
            var iconUrl : String?
            if let categories = venue["categories"] as? [[String: Any]],
                let primaryCategory = categories.first(where: {($0["primary"] as? Bool ?? false)}),
                let icon = primaryCategory["icon"] as? [String: String],
                let prefix = icon["prefix"], let suffix = icon["suffix"] {
                iconUrl = prefix + "bg_32" + suffix
            }
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: addr,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                postalCode: postalCode,
                distance: venue["distance"] as? Double,
                imageUrl: iconUrl
            )
        }.compactMap{ $0}
    }
    
    func _parseDetailsResultToModel(venue: [String: Any]) -> (PlaceInfoModel?, String) {
        guard let place_id = venue["id"] as? String,
            let name = venue["name"] as? String,
            let location = venue["location"] as? [String: Any],
            let lon = location["lng"] as? Double,
            let lat = location["lat"] as? Double,
            let addr = location["formattedAddress"] as? [String],
            let postalCode = location["postalCode"] as? String,
            let url = venue["canonicalUrl"] as? String else {
                let errorMessage = "Fails to denormalize essential details"
                logMessage("Fails to denormalize details")
                return (nil, errorMessage)
        }
        guard let score = venue["rating"] as? Double,
            let numOfScores = venue["ratingSignals"] as? Int else {
                logMessage("Fails to denormalize score, probably not rated")
                return (nil, "This place is not rated yet.")
        }
        let price = venue["price"] as? [String: Any]
        let hours = venue["hours"] as? [String: Any]
        let contact = venue["contact"] as? [String: String]
        let categoryList = venue["categories"] as? [[String: Any]]
        var imageUrl : String?
        if let bestPhoto = venue["bestPhoto"] as? [String: Any],
            let prefix = bestPhoto["prefix"] as? String,
            let suffix = bestPhoto["suffix"] as? String {
            imageUrl = "\(prefix)width\(Int(ceil(UIScreen.main.bounds.width)))\(suffix)"
        }
        return (PlaceInfoModel(
            place_id: place_id,
            name: name,
            formattedAddress: addr,
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            postalCode: postalCode,
            distance: venue["distance"] as? Double,
            score: score,
            numOfScores: numOfScores,
            url: url,
            price: price?["tier"] as? Int ?? 0,
            imageUrl: imageUrl,
            categories: categoryList?.map{ $0["name"] as? String }.compactMap{ $0},
            phone: contact?["formattedPhone"],
            hours: hours?["status"] as? String,
            open_now: hours?["isOpen"] as? Bool
        ), "")
    }
}
