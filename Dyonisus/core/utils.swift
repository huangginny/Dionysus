//
//  utils.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

func logMessage(_ message: String, fileName: String = #file, functionName: String = #function) {
    print("\(getCurrentTimestamp()) - [\(fileName.components(separatedBy: "/").last ?? "") - \(functionName)] \(message)")
}

func getCurrentTimestamp() -> String {
    let format = DateFormatter()
    format.timeZone = .current
    format.dateFormat = "HH:mm:ss.SSS Z"
    return format.string(from: Date())
}

func searchForPlaces(from name: String, location: String, with site: SitePlugin, doOnSearchComplete: @escaping([PlaceInfoModel], SitePlugin) -> Void) {
    site.searchForPlaces(with: name, location: location, callbackFunc: doOnSearchComplete)
}

func areSamePlaces(rating1: PlaceInfoModel, rating2: PlaceInfoModel) -> Bool {
    return false // FIXME
}
