//
//  models.swift
//  Dyonisus
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
    let formattedAddress: String
    let coordinate: CLLocationCoordinate2D
    
    // On rating card
    var score: Double?
    var numOfScores: Int?
    var url: String?
    var price = 0 // default value
    
    // Optional
    var imageUrl: String?
    var categories: [String]?
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
                    location: defaultPlace!.formattedAddress,
                    successCallbackFunc: _onPlaceFound,
                    errorCallbackFunc: {(plugin: SitePlugin) -> Void in
                        self.infoForSite[plugin.name]!.message = "Unable to find this place on \(plugin.name)."
                        self.infoForSite[plugin.name]!.isLoading = false
                    }
                );
            }
        }
    }
    
    func _onPlaceFound(results: [PlaceInfoModel], with plugin: SitePlugin) {
        logMessage("Found places for plugin \(plugin.name)")
        // select the correct rating for site, get holder on dictionary and update it
        for result in results {
            if areSamePlaces(rating1: result, rating2: defaultPlaceInfoLoader.place!) {
                infoForSite[plugin.name]!.place = result
                plugin.loadRatingAndDetails(
                    for: result,
                    successCallbackFunc: _onLoadRatingComplete,
                    errorCallbackFunc: _onLoadRatingError
                )
                return
            }
        }
        infoForSite[plugin.name]!.message = "Unable to find this place on \(plugin.name)."
    }
    
    func _onLoadRatingComplete(result: PlaceInfoModel, with plugin: SitePlugin) {
        logMessage("Found place \(result.name) for plugin \(plugin.name)")
        if plugin.name == defaultPlaceInfoLoader.plugin.name {
            defaultPlaceInfoLoader.place = result
            defaultPlaceInfoLoader.isLoading = false
            return
        }
        infoForSite[plugin.name]!.place = result
        infoForSite[plugin.name]!.isLoading = false
    }
    
    func _onLoadRatingError(with plugin: SitePlugin) {
        logMessage("Cannot retrieve rating for \(defaultPlaceInfoLoader.place!.name) with plugin \(plugin.name)")
        let msg = "This place is not yet rated."
        if plugin.name == defaultPlaceInfoLoader.plugin.name {
            defaultPlaceInfoLoader.message = msg
            defaultPlaceInfoLoader.isLoading = false
            return
        }
        infoForSite[plugin.name]!.message = msg
        infoForSite[plugin.name]!.isLoading = false
    }
}

/**
 Preview and debug helpers
 */
let previewPlugin = MockPlugin()
let cupboard = PlaceInfoModel(
    place_id: "Cupboard_Under_the_Stairs",
    name:"The Cupboard Under the Stairs",
    formattedAddress:"4 Privet Drive, Little Whinging, Surrey",
    coordinate: CLLocationCoordinate2D(latitude: 23.70870, longitude: -23.4567889),
    score:1.1,
    numOfScores: 4,
    url: "https://harrypotter.fandom.com/wiki/Cupboard_Under_the_Stairs",
    price: 1,
    categories: ["household"]
)
let ootp = PlaceInfoModel(
    place_id: "Order_of_the_Phoenix",
    name:"Order of the Phoenix HQ",
    formattedAddress:"12 Grimmauld Pl, London",
    coordinate: CLLocationCoordinate2D(latitude: 23.70870, longitude: -23.4567889),
    score:8.8,
    numOfScores: 28,
    url: "https://harrypotter.fandom.com/wiki/Order_of_the_Phoenix",
    price: 2,
    imageUrl: "https://vignette.wikia.nocookie.net/harrypotter/images/6/6f/HPDH1-1435.jpg", categories: ["organization"],
    hours:"9AM - 5PM, Mon - Fri"
)
let cupboards = PlaceHolderModel(with: cupboard, plugin: previewPlugin, setting: Setting())
var unrated = InfoLoader(plugin: previewPlugin, place: nil)
