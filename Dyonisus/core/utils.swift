//
//  utils.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation

func logMessage(_ message: String, fileName: String = #file, functionName: String = #function) {
    print("[DYONYSUS] | \(getCurrentTimestamp()) - \(fileName.components(separatedBy: "/").last ?? "") - \(functionName)  | \(message)")
}

func getCurrentTimestamp() -> String {
    let format = DateFormatter()
    format.timeZone = .current
    format.dateFormat = "HH:mm:ss.SSS Z"
    return format.string(from: Date())
}

func isNonEmptyString(_ str: String?) -> Bool {
    return str != nil && str!.trimmingCharacters(in: .whitespacesAndNewlines) != ""
}

func areSamePlaces(rating1: PlaceInfoModel, rating2: PlaceInfoModel) -> Bool {
    return true // FIXME : how close should coordinates be to determine sameness?
}

func loadUrl(
    urlString: String,
    authentication: String?,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
) {
    let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
    guard let url = URL(string: encodedUrlString) else {
        logMessage("URL \(encodedUrlString) is not a valid url")
        return
    }
    var request = URLRequest(url: url)
    if isNonEmptyString(authentication) {
        request.setValue(authentication, forHTTPHeaderField: "Authorization")
    }
    let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
    task.resume()
}
