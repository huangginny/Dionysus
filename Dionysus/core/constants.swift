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
    "4sq": FourSquarePlugin.self,
    "google": GooglePlugin.self,
]
let TIMEOUT_VALUE = 10
let PHOTO_HEIGHT = 240
let FUSE = Fuse(maxPatternLength: 64, tokenize: true)
let POWERS_OF_2 = [1,2,4,8,16,32,64,128,256,512]

/**
 Colors, palette from https://colorpalettes.net/color-palette-4013/
 */
let COLOR_LIGHT_GRAY = Color(UIColor.systemGray4)
let COLOR_THEME_ORANGE = getColorFromHex("#ff955f")
let COLOR_THEME_LIME = getColorFromHex("#a6c64c")
let COLOR_THEME_GREEN = getColorFromHex("#405d3a")
let COLOR_THEME_RED = getColorFromHex("#c80003")
