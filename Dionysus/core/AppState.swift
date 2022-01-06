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

enum DionysusView { case none, search, roll }

class AppState: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var setting : Setting
    @Published var currentView = DionysusView.none
    
    // Search
    @Published var placeSearchResults: [PlaceHolderModel] = []
    @Published var isPlaceSearchLoading = false
    @Published var placeSearchLoadError = ""
    var pluginOfPlaceSearchResults : SitePlugin?
    var ongoingSearchTermWithCoordinate = "" // a value would only exist when searching with coordinate
    
    // Dice
    @Published var diceResult: PlaceHolderModel?
    @Published var isDiceRolling = false
    @Published var diceRollError = ""
    
    // Location
    var locationAuthorizedStatus = CLAuthorizationStatus.notDetermined
    var locManager = CLLocationManager()
    
    override init() {
        // read settings from user defaults
        self.setting = Setting(defaultSite: "yelp", activeSites: ["yelp", "4sq", "google"])
        super.init()
        locManager.delegate = self
    }
    
    deinit {
        // save settings (in user defaults?)
    }
    
    func onSubmitSettingChange(defaultSite: String, activeSites: [String]) {
        setting = Setting(defaultSite: defaultSite, activeSites: activeSites)
    }
    
    func onSearchButtonClicked(with name:String, location:String) {
        logMessage("Searching with \(name) and \(location)...")
        if name == "" {
            return
        }
        isPlaceSearchLoading = true
        placeSearchLoadError = ""
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
    
    func onDiceRollClicked() {
        logMessage("Rolling dice...")
        isDiceRolling = true
        requestLocation()
    }
    
    func requestLocation() {
        switch locationAuthorizedStatus {
        case .restricted, .denied:
            if isPlaceSearchLoading {
                ongoingSearchTermWithCoordinate = ""
                isPlaceSearchLoading = false
                placeSearchLoadError = "Location services is not enabled. " +
                    "Please either enter a place name or enable your location services in device Settings."
            }
            if isDiceRolling {
                isDiceRolling = false
                diceRollError = "Location services is not enabled. " +
                    "Please enable your location services in device Settings to roll the dice."
            }
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
        if self.isPlaceSearchLoading {
            DispatchQueue.main.async {
                self.placeSearchResults = places.map{ PlaceHolderModel(with: $0, plugin: plugin, setting: self.setting)}
                self.pluginOfPlaceSearchResults = plugin
                self.isPlaceSearchLoading = false
            }
        }
        if self.isDiceRolling {
            let idx = places.count > 0 ? Int.random(in: 0 ..< places.count) : -1
            if idx == -1 {
                requestLocation() // roll dice again
            } else {
                DispatchQueue.main.async {
                    self.diceResult = PlaceHolderModel(with: places[idx], plugin: plugin, setting: self.setting)
                    self.isDiceRolling = false
                }
            }
        }
    }
    
    func _onPlaceSearchError(errorMessage: String, plugin: SitePlugin) {
        logMessage(errorMessage)
        if self.isPlaceSearchLoading {
            DispatchQueue.main.async {
                self.isPlaceSearchLoading = false
                self.placeSearchLoadError = errorMessage
            }
        }
    }
    
    func _onDiceRollError(errorMessage: String, plugin: SitePlugin) {
        logMessage(errorMessage)
        if self.isDiceRolling {
            DispatchQueue.main.async {
                self.isDiceRolling = false
                self.diceRollError = errorMessage
            }
        }
    }
    
/**
    CLLocationManagerExtension protocol methods
 */
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        logMessage("Authorization changed: \(status.rawValue)")
        locationAuthorizedStatus = status
        if (isPlaceSearchLoading && ongoingSearchTermWithCoordinate != "") || isDiceRolling {
            requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        logMessage("\(locations)")
        let location = locations.last
        if isDiceRolling {
            guard let coordinate = location?.coordinate else {
                isDiceRolling = false
                diceRollError = "Cannot retrieve location data from device."
                return
            }
            let idx = Int.random(in: 0 ..< setting.activeSitePlugins.count)
            setting.activeSitePlugins[idx].searchForPlaces(
                with: "Restaurants",
                coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude),
                successCallbackFunc: _onPlaceSearchComplete,
                errorCallbackFunc: _onDiceRollError
            )
        } else if isPlaceSearchLoading && ongoingSearchTermWithCoordinate != "" {
            guard let coordinate = location?.coordinate else {
                isPlaceSearchLoading = false
                placeSearchLoadError = "Cannot retrieve location data from device. Please enter a location in search."
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logMessage("\(error)")
        if isPlaceSearchLoading {
            isPlaceSearchLoading = false
            placeSearchLoadError = "Cannot retrieve location data from device. Please enter a location in search."
        }
        if isDiceRolling {
            isDiceRolling = false
            diceRollError = "Cannot retrieve location data from device."
        }
    }
}
