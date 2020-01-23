//
//  YelpPlugin.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/21/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
/**
class YelpPlugin : SitePlugin {
    
    var name = "Yelp"
    var logo = "yelp-icon"
    var totalScore = 5
    
    func _parseJsonToModels(json: [String: Any]) -> [PlaceInfoModel] {
        let businesses = json["businesses"] as! [[String: Any]]
        return businesses.map { (business: [String: Any]) -> PlaceInfoModel in
            PlaceInfoModel(
                name: business["name"],
                formattedAddress: business["location"]["display_address"].join(", "),
                categories: business["categories"].map{ $0["title"] },
                hours: "unknown",
                score: business["rating"],
                numOfScores: business["review_count"],
                url: business["url"],
                price: business["price"], // FIXME get length
                imageUrl: business["image_url"]
            )
        }
    }
    
    func _formatAddress(obj: Any) -> String {
        return "" // FIXME
    }
    
    func searchForPlaces(with name: String, location: String, successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void, errorCallbackFunc: @escaping (SitePlugin) -> Void) {
        var urlString = "https://api.yelp.com/v3/businesses/search?&term=\(name)&location=\(location)&categories=food"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        guard let url = URL(string: urlString) else {
            logMessage("URL \(urlString) is not a valid url")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
        task.resume()
    }
}
*/
