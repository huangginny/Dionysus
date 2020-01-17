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
    let id: Int
    let name: String
    let formattedAddress: String
    let categories: [String]
    let hours: String
    let score: Double
    let numOfScores: Int
    var url: String?
    
    static var instanceCounter = 0
    init(name:String, formattedAddress:String, categories:[String],
         hours:String, score:Double, numOfScores:Int) {
        self.id = PlaceInfoModel.instanceCounter
        self.name = name
        self.formattedAddress = formattedAddress
        self.categories = categories
        self.hours = hours
        self.score = score
        self.numOfScores = numOfScores
        
        PlaceInfoModel.instanceCounter += 1
    }
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
    score:5,
    numOfScores: 4
)
let ootp = PlaceInfoModel(
    name:"Order of the Phoenix HQ",
    formattedAddress:"12 Grimmauld Pl, London",
    categories: ["organization"],
    hours:"9-5",
    score:7,
    numOfScores: 28
)
let cupboards = PlaceHolderModel(with: cupboard, plugin: previewPlugin, activeSitePlugins: [])
