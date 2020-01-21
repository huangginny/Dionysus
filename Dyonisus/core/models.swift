//
//  models.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

struct Coordinates {
    var lat: String
    var lon: String
}

struct PlaceInfoModel : Identifiable {
    let id = UUID()
    let name: String
    let formattedAddress: String
    let categories: [String]
    let hours: String
    let score: Double
    let numOfScores: Int
    let url: String
    let price: Int
    let imageUrl: String
}

struct InfoLoader : Identifiable {
    var id: Int
    var isLoading: Bool
    var plugin: SitePlugin
    var place: PlaceInfoModel?
    
    static var instanceCounter = 0
    
    init(plugin: SitePlugin, place: PlaceInfoModel?) {
        self.id = InfoLoader.instanceCounter
        self.plugin = plugin
        self.isLoading = (place == nil)
        self.place = place
        
        InfoLoader.instanceCounter += 1
    }
}

class PlaceHolderModel: ObservableObject, Identifiable {
    
    @Published var infoForSite = [String : InfoLoader]()
    let defaultPlace : PlaceInfoModel
    
    init(with place: PlaceInfoModel, plugin: SitePlugin, activeSitePlugins: [SitePlugin]) {
        defaultPlace = place
        infoForSite[plugin.name] = InfoLoader(plugin: plugin, place: defaultPlace)
        for p in activeSitePlugins {
            if p.name != plugin.name {
                infoForSite[p.name] = InfoLoader(plugin: p, place: nil)
                p.searchForPlaces(with: defaultPlace.name, location: defaultPlace.formattedAddress, callbackFunc: _onRatingSearchComplete);
            }
        }
    }
    
    func _onRatingSearchComplete(results: [PlaceInfoModel], for plugin: SitePlugin) {
        // select the correct rating for site, get holder on dictionary and update it
        infoForSite[plugin.name]!.isLoading = false
        if results.count > 0 {
            infoForSite[plugin.name]!.place = results[0] //FIXME
        }
    }
}

/**
 Preview helpers
 */
let previewPlugin = MockPlugin()
let cupboard = PlaceInfoModel(
    name:"The Cupboard Under the Stairs",
    formattedAddress:"4 Privet Drive, Little Whinging, Surrey",
    categories: ["household"],
    hours:"12-12",
    score:1.1,
    numOfScores: 4,
    url: "https://harrypotter.fandom.com/wiki/Cupboard_Under_the_Stairs",
    price: 1,
    imageUrl: ""
)
let ootp = PlaceInfoModel(
    name:"Order of the Phoenix HQ",
    formattedAddress:"12 Grimmauld Pl, London",
    categories: ["organization"],
    hours:"9-5",
    score:8.8,
    numOfScores: 28,
    url: "https://harrypotter.fandom.com/wiki/Order_of_the_Phoenix",
    price: 2,
    imageUrl: "https://vignette.wikia.nocookie.net/harrypotter/images/6/6f/HPDH1-1435.jpg"
)
let cupboards = PlaceHolderModel(with: cupboard, plugin: previewPlugin, activeSitePlugins: [])
var unrated = InfoLoader(plugin: previewPlugin, place: nil)
