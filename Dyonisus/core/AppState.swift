//
//  AppState.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import Combine

let nameToSitePluginInitializer = [
    "mock": MockPlugin.init
]

struct Setting {
    var defaultSite = "mock" // use custom setters
    var defaultSitePlugin = MockPlugin()
    var defaultLocation = "10001"
    var activeSitePlugins = [SitePlugin]()
}

class AppState: ObservableObject {
    
    @Published var setting = Setting()
    @Published var placeSearchResults: [PlaceInfoModel] = []
    @Published var isLoading = false
    var pluginOfPlaceSearchResults : SitePlugin?
    
    init() {
        // read from json file
    }
    
    deinit {
        // save to json
    }
    
    func onSubmitSettingChange(defaultSite: String, activeSites: [String]) {
        var updatedSitePlugins = [SitePlugin]()
        for name in activeSites {
            let plugin = nameToSitePluginInitializer[name]!()
            updatedSitePlugins.append(plugin)
            if name == defaultSite {
                setting.defaultSitePlugin = plugin
            }
        }
        setting.activeSitePlugins = updatedSitePlugins
    }
    
    func onSearchButtonClicked(with name:String, location:String) {
        logMessage("Searching with \(name) and \(location)...")
        isLoading = true
        searchForPlaces(from: name, location: location, with: setting.defaultSitePlugin, doOnSearchComplete: _onPlaceSearchComplete)
    }

    func _onPlaceSearchComplete(places: [PlaceInfoModel], plugin: SitePlugin) {
        logMessage("Searching completed with \(places)")
        placeSearchResults = places
        pluginOfPlaceSearchResults = plugin
        isLoading = false
    }
}

