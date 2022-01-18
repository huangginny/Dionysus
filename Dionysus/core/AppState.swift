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

enum DionysusView { case none, search, roll }

class AppState: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var setting : PluginSetting
    @Published var currentView = DionysusView.none
    
    // Search
    @Published var placeSearchResults: [PlaceHolderModel] = []
    @Published var isPlaceSearchLoading = false
    @Published var placeSearchLoadError = ""
    var pluginOfPlaceSearchResults : SitePlugin?
    var ongoingSearchTermWithCoordinate = "" // a value would only exist when searching with coordinate
    
    // Dice
    @Published var diceResult: PlaceHolderModel?
    @Published var diceCategory: Category? = nil
    @Published var diceRollError = ""
    
    // Location
    var locationAuthorizedStatus = CLAuthorizationStatus.notDetermined
    var locManager = CLLocationManager()
    
    override init() {
        // read settings from user defaults
        self.setting = PluginSetting()
        super.init()
        locManager.delegate = self
    }
    
    deinit {
        // save settings (in user defaults?)
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
            filter: Filter(category: .anything),// TODO: change when filter is implemented
            location: location,
            successCallbackFunc: _onPlaceSearchComplete,
            errorCallbackFunc: _onPlaceSearchError
        )
    }
    
    func onDiceRollClicked(category: Category) {
        logMessage("Rolling dice...")
        self.currentView = DionysusView.roll
        diceCategory = category
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
            if diceCategory != nil {
                diceCategory = nil
                diceRollError = "Location services is not enabled. " +
                    "Please enable your location services in device Settings to roll the dice."
            }
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locManager.requestLocation()
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
        if self.diceCategory != nil {
            let idx = places.count > 0 ? Int.random(in: 0 ..< places.count) : -1
            if idx == -1 {
                requestLocation() // roll dice again
            } else {
                DispatchQueue.main.async {
                    self.diceResult = PlaceHolderModel(with: places[idx], plugin: plugin, setting: self.setting)
                    self.diceCategory = nil
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
        if self.diceCategory != nil {
            DispatchQueue.main.async {
                self.diceCategory = nil
                self.diceRollError = errorMessage
            }
        }
    }
    
/**
    CLLocationManagerExtension protocol methods
 */

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizedStatus = manager.authorizationStatus
        logMessage("Authorization changed: \(locationAuthorizedStatus.rawValue)")
        if (isPlaceSearchLoading && ongoingSearchTermWithCoordinate != "") ||
            diceCategory != nil {
            requestLocation()
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        logMessage("\(locations)")
        let location = locations.last
        if diceCategory != nil {
            guard let coordinate = location?.coordinate else {
                diceCategory = nil
                diceRollError = "Cannot retrieve location data from device."
                return
            }
            let idx = Int.random(in: 0 ..< setting.defaultAndActivePlugins.count)
            setting.defaultAndActivePlugins[idx].searchForPlaces(
                with: "",
                filter: Filter(category: diceCategory),
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
                filter: Filter(category: .anything), // TODO: change when filter is implemented
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
        if diceCategory != nil {
            diceCategory = nil
            diceRollError = "Cannot retrieve location data from device."
        }
    }
}
