//
//  AppState.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

struct Setting {
    var defaultSite = "mock" // use custom setters
    var defaultSitePlugin = MockPlugin()
    var defaultLocation = "10001"
    var activeSitePlugins = [SitePlugin]()
}

class AppState: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var setting = Setting()
    @Published var placeSearchResults: [PlaceInfoModel] = []
    @Published var isLoading = false
    @Published var loadError = ""
    
    var pluginOfPlaceSearchResults : SitePlugin?
    
    var isLocationAuthorized = false
    var locManager = CLLocationManager()
    var ongoingSearchTerm = ""
    
    override init() {
        super.init()
        // read settings from json file
        locManager.delegate = self
    }
    
    deinit {
        // save settings to json
    }
    
    func onSubmitSettingChange(defaultSite: String, activeSites: [String]) {
        var updatedSitePlugins = [SitePlugin]()
        for name in activeSites {
            let plugin = NAME_TO_SITE_PLUGIN[name]!()
            updatedSitePlugins.append(plugin)
            if name == defaultSite {
                setting.defaultSitePlugin = plugin
            }
        }
        setting.activeSitePlugins = updatedSitePlugins
    }
    
    func onSearchButtonClicked(with name:String, location:String) {
        logMessage("Searching with \(name) and \(location)...")
        if name == "" {
            return
        }
        if location == "" {
            ongoingSearchTerm = name
            if isLocationAuthorized {
                locManager.requestLocation()
                isLoading = true
            } else {
                locManager.requestWhenInUseAuthorization()
            }
            return
        }
        isLoading = true
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
        placeSearchResults = places
        pluginOfPlaceSearchResults = plugin
        isLoading = false
    }
    
    func _onPlaceSearchError(plugin: SitePlugin) {
        logMessage("")
        isLoading = false
        loadError = "Error encountered when searching with \(plugin.name). Please check your network connections."
    }
    
/**
    CLLocationManagerExtension protocol methods
 */
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        logMessage("Authorization changed: \(status.rawValue)")
        isLocationAuthorized = status == CLAuthorizationStatus.authorizedWhenInUse
        if isLocationAuthorized {
            locManager.requestLocation()
            isLoading = true
        } else {
            ongoingSearchTerm = ""
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
