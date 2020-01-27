//
//  AppState.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

struct Setting {
    var defaultSite : String
    var defaultSitePlugin : SitePlugin
    var activeSitePlugins = [SitePlugin]()
    
    init(defaultSite : String, activeSites: [String]) {
        self.defaultSite = defaultSite
        self.defaultSitePlugin = NAME_TO_SITE_PLUGIN[defaultSite]!.init()
        
        var updatedSitePlugins = [self.defaultSitePlugin]
        for name in activeSites {
            if name != defaultSite {
                let plugin = NAME_TO_SITE_PLUGIN[name]!.init()
                updatedSitePlugins.append(plugin)
            }
        }
        self.activeSitePlugins = updatedSitePlugins
    }
}

class AppState: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var setting : Setting
    @Published var placeSearchResults: [PlaceInfoModel] = []
    @Published var isLoading = false
    @Published var loadError = ""
    
    var pluginOfPlaceSearchResults : SitePlugin?
    
    var isLocationAuthorized = false
    var locManager = CLLocationManager()
    var ongoingSearchTerm = ""
    
    override init() {
        // read settings from json file
        //self.setting = Setting(defaultSite: "yelp", activeSites: ["4sq", "mock"])
        self.setting = Setting(defaultSite: "4sq", activeSites: ["4sq", "yelp"])
        super.init()
        locManager.delegate = self
    }
    
    deinit {
        // save settings to json
    }
    
    func onSubmitSettingChange(defaultSite: String, activeSites: [String]) {
        setting = Setting(defaultSite: defaultSite, activeSites: activeSites)
    }
    
    func onSearchButtonClicked(with name:String, location:String) {
        logMessage("Searching with \(name) and \(location)...")
        if name == "" {
            return
        }
        isLoading = true
        if location == "" {
            ongoingSearchTerm = name
            if isLocationAuthorized {
                locManager.requestLocation()
            } else {
                locManager.requestWhenInUseAuthorization()
            }
            return
        }
        loadError = ""
        setting.defaultSitePlugin.searchForPlaces(
            with: name,
            location: location,
            successCallbackFunc: _onPlaceSearchComplete,
            errorCallbackFunc: _onPlaceSearchError
        )
    }

    func _onPlaceSearchComplete(places: [PlaceInfoModel], plugin: SitePlugin) {
        logMessage("Searching completed with \(places)")
        DispatchQueue.main.async {
            self.placeSearchResults = places
            self.pluginOfPlaceSearchResults = plugin
            self.isLoading = false
        }
    }
    
    func _onPlaceSearchError(errorMessage: String, plugin: SitePlugin) {
        logMessage(errorMessage)
        DispatchQueue.main.async {
            self.isLoading = false
            self.loadError = errorMessage
        }
    }
    
/**
    CLLocationManagerExtension protocol methods
 */
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        logMessage("Authorization changed: \(status.rawValue)")
        isLocationAuthorized = status == CLAuthorizationStatus.authorizedWhenInUse
        if isLocationAuthorized && isLoading == true {
            locManager.requestLocation()
        } else {
            // declined authorization
            ongoingSearchTerm = ""
            isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        logMessage("\(locations)")
        let location = locations.last
        guard let coordinate = location?.coordinate else {
            isLoading = false
            loadError = "Cannot retrieve location data from device. Please enter a location in search."
            return
        }
        setting.defaultSitePlugin.searchForPlaces(
            with: ongoingSearchTerm,
            coordinate: coordinate,
            successCallbackFunc: _onPlaceSearchComplete,
            errorCallbackFunc: _onPlaceSearchError
        )
        ongoingSearchTerm = ""
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logMessage("\(error)")
        isLoading = false
        loadError = "Cannot retrieve location data from device. Please enter a location in search."
    }
}
