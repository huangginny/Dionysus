//
//  YelpPlugin.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/21/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

class YelpPlugin : SitePlugin {
    
    var name: String
    var attribution: String
    var attributionHasText: Bool
    var faviconUrl: String
    var colorCode: String
    var totalScore: Int
    
    let baseUrl = "https://api.yelp.com/v3/businesses/search?"
    
    required init() {
        name = "Yelp"
        attribution = "yelp-icon"
        attributionHasText = false
        faviconUrl = "https://www.yelp.com/favicon.ico"
        colorCode = "#D32323"
        totalScore = 5
    }
    
    class func getImageAssetName(score: Double) -> String {
        switch score {
        case 5.0...:
            return "regular_5"
        case 4.5 ..< 5.0:
            return "regular_4_half"
        case 4.0 ..< 4.5:
            return "regular_4"
        case 3.5 ..< 4.0:
            return "regular_3_half"
        case 3.0 ..< 3.5:
            return "regular_3"
        case 2.5 ..< 3.0:
            return "regular_2_half"
        case 2.0 ..< 2.5:
            return "regular_2"
        case 1.5 ..< 2.0:
            return "regular_1_half"
        default:
            return "regular_1"
        }
    }
    
    func searchForPlaces(
        with name: String,
        filter: Filter,
        location: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        logMessage("")
        let urlString = baseUrl + "term=\(name)&location=\(location)" +
            "&categories=\(_stringFromCategory(filter.category))"
        self._searchForPlacesHelper(
            with: urlString,
            successCallbackFunc: successCallbackFunc,
            errorCallbackFunc: errorCallbackFunc
        )
    }
    
    func searchForPlaces(
        with name: String,
        filter: Filter,
        coordinate: Coordinate,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        logMessage("")
        let urlString = baseUrl + "term=\(name)&latitude=\(coordinate.latitude)&longitude=" +
            "\(coordinate.longitude)&categories=\(_stringFromCategory(filter.category))"
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
        if let _ = place.score, let _ = place.numOfScores {
            logMessage("Score exists")
            successCallbackFunc(place, self)
        } else {
            logMessage("Score does not exist for place \(place)")
            errorCallbackFunc("This place is not rated yet.", self)
        }
    }
    
    func _searchForPlacesHelper(
        with url: String,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void
    ) {
        logMessage("URL: \(url)")
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
    
    func _stringFromCategory(_ category: Category?) -> String {
        // https://www.yelp.com/developers/documentation/v3/all_category_list
        guard let cat = category else { return "" }
        switch cat {
        case .anything:
            return "food,restaurants"
        case .breakfast:
            return "baguettes,breakfast_brunch,bagels,bakeries,gourmet"
        case .lunch:
            return "restaurants,bento,poke,gourmet"
        case .dinner:
            return "restaurants,poke,gourmet"
        case .cafe:
            return "coffeeshops,breweries,coffee,cakeshop,tea,baguettes,bakeries,bubbletea"
        case .dessert:
            return "chimneycakes,churros,cupcakes,shavedsnow,sugarshacks" +
                "desserts,donuts,gelato,icecream,jpsweets,cakeshop,shavedice"
        case .nightlife:
            return "nightlife,beer_and_wine,breweries,wineries"
        }
    }
    
    func _parseJsonToModels(jsonList: [[String: Any]]) -> [PlaceInfoModel] {
        return jsonList.compactMap { (biz: [String: Any]) -> PlaceInfoModel? in
            guard let place_id = biz["id"] as? String,
                let name = biz["name"] as? String,
                let location = biz["location"] as? [String: Any],
                let coordinate = biz["coordinates"] as? [String: Double],
                let lon = coordinate["longitude"],
                let lat = coordinate["latitude"],
                let addr = location["display_address"] as? [String],
                let postalCode = location["zip_code"] as? String else {
                    logMessage("Fails to denormalize basic information")
                    return nil
            }
            let categoryList = biz["categories"] as? [[String: String?]] ?? [[String: String?]]()
            return PlaceInfoModel(
                place_id: place_id,
                name: name,
                formattedAddress: addr,
                coordinate: Coordinate(latitude: lat, longitude: lon),
                postalCode: postalCode,
                
                score: biz["rating"] as? Double,
                numOfScores: biz["review_count"] as? Int,
                url: biz["url"] as? String,
                price: (biz["price"] as? String)?.count ?? 0,
                
                imageUrl: biz["image_url"] as? String,
                categories: categoryList.compactMap{ $0["title"] as? String },
                distance: biz["distance"] as? Double,
                phone: biz["display_phone"] as? String,
                permanently_closed: biz["is_closed"] as? Bool
            )
        }
    }
}

