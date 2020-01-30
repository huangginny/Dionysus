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
    
    var locationAuthorizedStatus = CLAuthorizationStatus.notDetermined
    var locManager = CLLocationManager()
    var ongoingSearchTermWithCoordinate = "" // a value would only exist when searching with coordinate
    
    override init() {
        // read settings from json file
        //self.setting = Setting(defaultSite: "yelp", activeSites: ["4sq", "mock"])
        self.setting = Setting(defaultSite: "yelp", activeSites: ["4sq", "yelp"])
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
        loadError = ""
        if location == "" {
            ongoingSearchTermWithCoordinate = name
            requestLocation()
            return
        }
        setting.defaultSitePlugin.searchForPlaces(
            with: name,
            location: location,
            successCallbackFunc: _onPlaceSearchComplete,
            errorCallbackFunc: _onPlaceSearchError
        )
    }
    
    func requestLocation() {
        switch locationAuthorizedStatus {
        case .restricted, .denied:
            ongoingSearchTermWithCoordinate = ""
            isLoading = false
            loadError = "Location services is not enabled. " +
                "Please either enter a place name or enable your location services in device Settings."
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locManager.startUpdatingLocation()
            break
        default:
            locManager.requestWhenInUseAuthorization()
        }
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
        locationAuthorizedStatus = CLAuthorizationStatus.authorizedWhenInUse
        if isLoading && ongoingSearchTermWithCoordinate != "" {
            requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        logMessage("\(locations)")
        if !isLoading || ongoingSearchTermWithCoordinate == "" {
            return
        }
        let location = locations.last
        guard let coordinate = location?.coordinate else {
            isLoading = false
            loadError = "Cannot retrieve location data from device. Please enter a location in search."
            return
        }
        setting.defaultSitePlugin.searchForPlaces(
            with: ongoingSearchTermWithCoordinate,
            coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude),
            successCallbackFunc: _onPlaceSearchComplete,
            errorCallbackFunc: _onPlaceSearchError
        )
        ongoingSearchTermWithCoordinate = ""
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logMessage("\(error)")
        isLoading = false
        loadError = "Cannot retrieve location data from device. Please enter a location in search."
    }
}
