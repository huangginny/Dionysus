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
    onSuccess: @escaping(_ data: Data) -> Void,
    onError: @escaping() -> Void
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
    let task = URLSession.shared.dataTask(with: request, completionHandler: {
        (data:Data?, response:URLResponse?, error:Error?) -> Void in
        if let error = error {
            logMessage("Error when searching with 4sq: \(error)")
            onError()
            return
        }
        let httpResponse = response as? HTTPURLResponse
        if httpResponse == nil || (200...299).contains(httpResponse!.statusCode) == false {
            logMessage("Error when searching with 4sq" +
                (httpResponse == nil ? "" : ": status code = \(httpResponse!.statusCode)"))
            onError()
            return
        }
        if let mimeType = httpResponse!.mimeType, mimeType == "application/json",
            let data = data {
            onSuccess(data)
        }
    })
    task.resume()
}
