//
//  FourSquarePlugin.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/24/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

class FourSquarePlugin: SitePlugin {
    
    var name: String
    var attribution: String
    var attributionHasText: Bool
    var faviconUrl: String
    var colorCode: String
    var totalScore: Int
    
    let baseUrl = "https://api.foursquare.com/v2/venues/"
    let authParams = "&client_id=\(FOURSQUARE_CLIENT_ID)" +
        "&client_secret=\(FOURSQUARE_CLIENT_SECRET)&v=\(FOURSQUARE_VERSION)"
    
    required init() {
        name = "FourSquare"
        attribution = "powered-by-4sq"
        attributionHasText = true
        faviconUrl = "https://foursquare.com/favicon.ico"
        colorCode = "#F94877"
        totalScore = 10
    }
    
    func searchForPlaces(
        with name: String,
        filter: Filter,
        location: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
            let url = baseUrl + "search?near=\(location)&query=\(name)&categories=" +
                "\(_stringFromCategory(filter.category))" + authParams
        _searchForPlaces(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func searchForPlaces(
        with name: String,
        filter: Filter,
        coordinate: Coordinate,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        let url = baseUrl + "search?ll=\(coordinate.latitude),\(coordinate.longitude)&query=\(name)" +
            "\(_stringFromCategory(filter.category))" + authParams
        _searchForPlaces(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func _searchForPlaces(
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
                    let (model, errorMsg) = self._parseDetailsResultToModel(venue: venue, original: place)
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
    
    func _stringFromCategory(_ category: Category?) -> String {
        // https://developer.foursquare.com/docs/categories
        guard let cat = category else { return "" }
        switch cat {
        case .anything:
            return "13000"
        case .breakfast:
            return "13001,13002,13028,13052,13053,13054,13065"
        case .lunch:
            return "13037,13052,13053,13054,13065"
        case .dinner:
            return "13037,13052,13053,13054,13065"
        case .cafe:
            return "13032"
        case .dessert:
            return "13040"
        case .nightlife:
            return "13003,13029,13038,13050"
        }
    }
    
    func _parseSearchResultToModels(venues: [[String: Any]]) -> [PlaceInfoModel] {
        return venues.compactMap { (venue: [String: Any]) -> PlaceInfoModel? in
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
                iconUrl = prefix + "bg_64" + suffix
            }
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: addr,
                coordinate: Coordinate(latitude: lat, longitude: lon),
                postalCode: postalCode,
                imageUrl: iconUrl,
                distance: location["distance"] as? Double
            )
        }
    }
    
    func _parseDetailsResultToModel(venue: [String: Any], original: PlaceInfoModel) -> (PlaceInfoModel?, String) {
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
            imageUrl = "\(prefix)width\(getScreenWidth())\(suffix)"
        }
        return (PlaceInfoModel(
            place_id: place_id,
            name: name,
            formattedAddress: addr,
            coordinate: Coordinate(latitude: lat, longitude: lon),
            postalCode: postalCode,
            
            score: score,
            numOfScores: numOfScores,
            url: url,
            price: price?["tier"] as? Int ?? 0,
            imageUrl: imageUrl,
            categories: categoryList?.compactMap{ $0["name"] as? String } ?? [String](),
            distance: location["distance"] as? Double ?? original.distance,
            phone: contact?["formattedPhone"],
            hours: hours?["status"] as? String,
            open_now: hours?["isOpen"] as? Bool
        ), "")
    }
}
