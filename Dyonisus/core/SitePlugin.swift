//
//  SitePlugin.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/16/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

/*
 Abstract class that defines SitePlugin protocol
 */
protocol SitePlugin {
    
    var name: String { get }
    var logo: String { get }
    var totalScore: Int { get }
            
    func searchForPlaces(with name:String, location: String, callbackFunc: @escaping([PlaceInfoModel], SitePlugin) -> Void)
}

/*
delete later
*/
class MockPlugin : SitePlugin {
    
    var name = "Mock Plugin"
    var logo = "mock-plugin-logo"
    var totalScore = 10
    
    func searchForPlaces(with name:String, location: String, callbackFunc: @escaping([PlaceInfoModel], SitePlugin) -> Void) {
        logMessage("Searching...")
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            callbackFunc([cupboard, ootp], self);
        }
    }
}
