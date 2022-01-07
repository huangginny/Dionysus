//
//  SitePlugin.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/16/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import CoreLocation

/*
 Abstract class that defines SitePlugin protocol
 */
protocol SitePlugin {
    
    var name: String { get }
    var attribution: String { get }
    var attributionHasText: Bool { get }
    var faviconUrl: String { get }
    var colorCode: String { get }
    var totalScore: Int { get }
    
    init()
            
    func searchForPlaces(
        with name:String,
        location: String,
        successCallbackFunc: @escaping([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping(String, SitePlugin) -> Void
    )
    
    func searchForPlaces(
        with name:String,
        coordinate: Coordinate,
        successCallbackFunc: @escaping([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping(String, SitePlugin) -> Void
    )
    
    func loadRatingAndDetails (
        for place: PlaceInfoModel,
        successCallbackFunc: @escaping(PlaceInfoModel, SitePlugin) -> Void,
        errorCallbackFunc: @escaping(String, SitePlugin) -> Void
    )
}

class MockPlugin : SitePlugin {
    
    var name: String
    var attribution: String
    var attributionHasText: Bool
    var faviconUrl: String
    var colorCode: String
    var totalScore: Int
    
    required init() {
        name = "Mock Plugin"
        attribution = "mock-plugin-logo"
        attributionHasText = false
        faviconUrl = "https://github.com/favicon.ico"
        colorCode = "#EB5244"
        totalScore = 10
    }
    
    func searchForPlaces(
        with name:String,
        location: String,
        successCallbackFunc: @escaping([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping(String, SitePlugin) -> Void) {
        
        logMessage("Searching with location: \(location)")
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            successCallbackFunc([cupboard, ootp], self);
        }
    }
    
    func searchForPlaces(
        with name: String,
        coordinate: Coordinate,
        successCallbackFunc: @escaping ([PlaceInfoModel], SitePlugin) -> Void,
        errorCallbackFunc: @escaping (String, SitePlugin) -> Void) {
        
        logMessage("Searching with coordinate: \(coordinate)")
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            successCallbackFunc([cupboard, ootp], self);
        }
    }
    
    func loadRatingAndDetails (
        for place: PlaceInfoModel,
        successCallbackFunc: @escaping(PlaceInfoModel, SitePlugin) -> Void,
        errorCallbackFunc: @escaping(String, SitePlugin) -> Void
    ) {
        logMessage("Loading defails for place: \(place.name)")
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            successCallbackFunc(ootp, self);
        }
    }
}
