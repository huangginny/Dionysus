//
//  models.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

struct PlaceInfoModel : Identifiable {
    let id = UUID()
    let place_id: String
    let name: String
    let formattedAddress: [String]
    let coordinate: CLLocationCoordinate2D
    let postalCode: String
    
    // On rating card
    var score: Double?
    var numOfScores: Int?
    var url: String?
    var price = 0 // default value
    
    // Optional
    var imageUrl: String?
    var categories: [String]?
    var distance: Double?
    var phone: String?
    var hours: String?
    var open_now: Bool?
    var permanently_closed: Bool?
}

struct InfoLoader : Identifiable {
    var id: Int
    var isLoading = true
    var plugin: SitePlugin
    var place: PlaceInfoModel?
    var message = ""
    
    static var instanceCounter = 0
    
    init(plugin: SitePlugin, place: PlaceInfoModel?) {
        self.id = InfoLoader.instanceCounter
        self.plugin = plugin
        self.place = place
        
        InfoLoader.instanceCounter += 1
    }
}

class PlaceHolderModel: ObservableObject, Identifiable {
    
    @Published var infoForSite = [String : InfoLoader]()
    @Published var defaultPlaceInfoLoader : InfoLoader
    let currentSetting : Setting
    
    init(with place: PlaceInfoModel, plugin: SitePlugin, setting: Setting) {
        currentSetting = setting
        defaultPlaceInfoLoader = InfoLoader(plugin: plugin, place: place)
    }
    
    func loadPlaces() {
        logMessage("Loading place: \(defaultPlaceInfoLoader.place?.name ?? "")")
        defaultPlaceInfoLoader.plugin.loadRatingAndDetails(
            for : defaultPlaceInfoLoader.place!,
            successCallbackFunc: _onLoadRatingComplete,
            errorCallbackFunc: _onLoadRatingError
        );
        let defaultPlace = defaultPlaceInfoLoader.place
        for p in currentSetting.activeSitePlugins {
            if p.name != defaultPlaceInfoLoader.plugin.name {
                infoForSite[p.name] = InfoLoader(plugin: p, place: nil)
                p.searchForPlaces(
                    with: defaultPlace!.name,
                    coordinate: defaultPlace!.coordinate,
                    successCallbackFunc: _onPlaceFound,
                    errorCallbackFunc: {(errorMessage: String, plugin: SitePlugin) -> Void in
                        self.infoForSite[plugin.name]!.message = errorMessage
                        self.infoForSite[plugin.name]!.isLoading = false
                    }
                );
            }
        }
    }
    
    func _onPlaceFound(results: [PlaceInfoModel], with plugin: SitePlugin) {
        logMessage("Found places for plugin \(plugin.name)")
        // select the correct rating for site, get holder on dictionary and update it
        if let result = getBestMatchByFuzzyDistance(
            with: defaultPlaceInfoLoader.place!,
            candidates: results) {
            logMessage("Best match found: \(result)")
            DispatchQueue.main.async {
                self.infoForSite[plugin.name]!.place = result
                plugin.loadRatingAndDetails(
                    for: result,
                    successCallbackFunc: self._onLoadRatingComplete,
                    errorCallbackFunc: self._onLoadRatingError
                )
            }
            return
        }
        logMessage("No match could be found")
        _onLoadRatingError(errorMessage: "Unable to find this place on \(plugin.name).", plugin: plugin)
    }
    
    func _onLoadRatingComplete(result: PlaceInfoModel, with plugin: SitePlugin) {
        logMessage("Found place \(result.name) for plugin \(plugin.name)")
        DispatchQueue.main.async {
            if plugin.name == self.defaultPlaceInfoLoader.plugin.name {
                self.defaultPlaceInfoLoader.place = result
                self.defaultPlaceInfoLoader.isLoading = false
                return
            }
            self.infoForSite[plugin.name]!.place = result
            self.infoForSite[plugin.name]!.isLoading = false
        }
    }
    
    func _onLoadRatingError(errorMessage: String, plugin: SitePlugin) {
        logMessage("Cannot retrieve rating for \(defaultPlaceInfoLoader.place!.name) with plugin \(plugin.name)." +
            "Error: \(errorMessage)")
        DispatchQueue.main.async {
            if plugin.name == self.defaultPlaceInfoLoader.plugin.name {
                self.defaultPlaceInfoLoader.message = errorMessage
                self.defaultPlaceInfoLoader.isLoading = false
                return
            }
            self.infoForSite[plugin.name]!.message = errorMessage
            self.infoForSite[plugin.name]!.isLoading = false
        }
    }
}

/**
 Preview and debug helpers
 */
let mockSetting = Setting(defaultSite: "mock", activeSites: [])
let cupboard = PlaceInfoModel(
    place_id: "Cupboard_Under_the_Stairs",
    name:"The Cupboard Under the Stairs",
    formattedAddress: ["4 Privet Drive", "Little Whinging","Surrey","United Kingdom"],
    coordinate: CLLocationCoordinate2D(latitude: 23.70870, longitude: -23.4567889),
    postalCode: "SE1 2SW",
    score:1.1,
    numOfScores: 4,
    url: "https://harrypotter.fandom.com/wiki/Cupboard_Under_the_Stairs",
    price: 1,
    categories: ["household"]
)
let ootp = PlaceInfoModel(
    place_id: "Order_of_the_Phoenix",
    name:"Order of the Phoenix HQ",
    formattedAddress: ["12 Grimmauld Pl", "London"],
    coordinate: CLLocationCoordinate2D(latitude: 23.70870, longitude: -23.4567889),
    postalCode: "SE1 2SW",
    score:8.8,
    numOfScores: 28,
    url: "https://harrypotter.fandom.com/wiki/Order_of_the_Phoenix",
    price: 2,
    imageUrl: "https://vignette.wikia.nocookie.net/harrypotter/images/6/6f/HPDH1-1435.jpg", categories: ["organization"],
    hours:"9AM - 5PM, Mon - Fri"
)
let cupboards = PlaceHolderModel(with: cupboard, plugin: mockSetting.defaultSitePlugin, setting: mockSetting)
var unrated = InfoLoader(plugin: mockSetting.defaultSitePlugin, place: nil)
