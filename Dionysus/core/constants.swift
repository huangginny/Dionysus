//
//  constants.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/22/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import Foundation
import SwiftUI
import Fuse

let NAME_TO_SITE_PLUGIN: [String: SitePlugin.Type] = [
    "mock": MockPlugin.self,
    "yelp": YelpPlugin.self,
    "4sq": FourSquarePlugin.self
]
let COLOR_LIGHT_GRAY = Color(UIColor(red:0.90, green:0.89, blue:0.89, alpha:1.0))
let TIMEOUT_VALUE = 10
let PHOTO_HEIGHT = 240
let FUSE = Fuse(maxPatternLength: 64, tokenize: true)
