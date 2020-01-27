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
    var logo: String { get }
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
        coordinate: CLLocationCoordinate2D,
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
    var logo: String
    var totalScore: Int
    
    required init() {
        name = "Mock Plugin"
        logo = "mock-plugin-logo"
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
        coordinate: CLLocationCoordinate2D,
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
