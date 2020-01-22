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

func areSamePlaces(rating1: PlaceInfoModel, rating2: PlaceInfoModel) -> Bool {
    return true // FIXME : how close should coordinates be to determine sameness?
}
