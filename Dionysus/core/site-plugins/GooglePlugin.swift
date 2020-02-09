//
//  GooglePlugin.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/1/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

class GooglePlugin : SitePlugin {
    
    var name: String
    var attribution: String
    var attributionHasText: Bool
    var colorCode: String
    var totalScore: Int
    
    let BASE_URL_SEARCH = "https://maps.googleapis.com/maps/api/place/textsearch/json?key=\(GOOGLE_API_KEY)&"
    
    required init() {
        name = "Google"
        attribution = "powered-by-google"
        attributionHasText = true
        colorCode = "#4285f4"
        totalScore = 5
    }
    
    func searchForPlaces(with name: String, location: String, successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void, errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        logMessage("")
        let url = "\(BASE_URL_SEARCH)query=\(name) \(location)"
        _searchForPlacesHelper(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func searchForPlaces(with name: String, coordinate: Coordinate, successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void, errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        logMessage("")
        let url = "\(BASE_URL_SEARCH)query=\(name)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=1600"
        _searchForPlacesHelper(with: url, successCallbackFunc: successCallbackFunc, errorCallbackFunc: errorCallbackFunc)
    }
    
    func loadRatingAndDetails(for place: PlaceInfoModel, successCallbackFunc: @escaping (PlaceInfoModel, SitePlugin) -> Void, errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        guard let _ = place.score, let _ = place.numOfScores else {
            errorCallbackFunc("This place is not rated yet", self)
            return
        }
        let url = "https://maps.googleapis.com/maps/api/place/details/json?key=\(GOOGLE_API_KEY)" +
            "&place_id=\(place.place_id)&fields=photo,permanently_closed,url,address_component"
        loadUrl(
            urlString: url,
            authentication: nil,
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let result = json["result"] as? [String: Any] {
                    let (model, errorMsg) = self._parseDetailsResultToModel(result: result, original: place)
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
    
    func _searchForPlacesHelper(
        with url: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        logMessage("Url: \(url)")
        loadUrl(
            urlString: url,
            authentication: nil,
            onSuccess: {(data: Data) -> Void in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = json["results"] as? [[String: Any]]{
                    let models = self._parseSearchResultsToModels(jsonList: results)
                    successCallbackFunc(models, self)
                } else {
                    errorCallbackFunc("An error occurred when retrieving places from Google.", self) // fixme
                }
            },
            onError: {(errorMsg: String) -> Void in errorCallbackFunc(errorMsg, self)}
        )
    }
    
    func _parseSearchResultsToModels(jsonList: [[String: Any]]) -> [PlaceInfoModel] {
        return jsonList.map { (result: [String: Any]) -> PlaceInfoModel? in
            guard let place_id = result["place_id"] as? String,
                let name = result["name"] as? String,
                let formattedAddress = result["formatted_address"] as? String,
                let geometry = result["geometry"] as? [String: Any],
                let coordinate = geometry["location"] as? [String: Double],
                let lon = coordinate["lng"],
                let lat = coordinate["lat"] else {
                    logMessage("Fails to denormalize basic information")
                    return nil
            }
            var isOpen = Optional<Bool>.none
            if let hours = result["opening_hours"] as? [String: Bool],
                let open_now = hours["open_now"] {
                isOpen = open_now
            }
            
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: formattedAddress.components(separatedBy: ", "),
                coordinate: Coordinate(latitude: lat, longitude: lon),
                
                score: result["rating"] as? Double,
                numOfScores: result["user_ratings_total"] as? Int,
                price: result["price_level"] as? Int ?? 0,
                imageUrl: result["icon"] as? String,
                open_now: isOpen
            )
        }.compactMap{ $0}
    }
    
    func _parseDetailsResultToModel(result: [String: Any], original: PlaceInfoModel) -> (PlaceInfoModel?, String) {
        var imageUrl = Optional<String>.none
        if let photos = result["photos"] as? [[String : Any]],
            let photo = photos.first,
            let reference = photo["photo_reference"] as? String {
            imageUrl = "https://maps.googleapis.com/maps/api/place/photo?key=\(GOOGLE_API_KEY)" +
                "&photoreference=\(reference)&maxwidth=\(getScreenWidth())"
        }
        
        var postalCode = Optional<String>.none
        if let addrComponents = result["address_components"] as? [[String: Any]],
            let postalCodeComponent = addrComponents.filter({
                if let componentType = $0["types"] as? [String] {
                    return componentType.contains("postal_code")
                }
                return false
            }).first {
            postalCode = postalCodeComponent["long_name"] as? String
        }
        
        var message = "This place is not rated yet."
        if let score = original.score, round(score) > 0 {
            message = ""
        }
        
        return (PlaceInfoModel(
            place_id: original.place_id,
            name: original.name,
            formattedAddress: original.formattedAddress,
            coordinate: original.coordinate,
            postalCode: postalCode,
            score: original.score,
            numOfScores: original.numOfScores,
            url: result["url"] as? String,
            price: original.price,
            imageUrl: imageUrl,
            open_now: original.open_now,
            permanently_closed: result["permanently_closed"] as? Bool
        ), message)
    }
}
