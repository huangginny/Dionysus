//
//  SettingsModel.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/6/22.
//  Copyright © 2022 Ginny Huang. All rights reserved.
//

import Foundation
import Combine

class Setting: ObservableObject {
    @Published var defaultSitePlugin : SitePlugin
    
    var defaultSite : String
    // TODO: should be published once inactive plugins are supported.
    var activeSitePlugins = [SitePlugin]()
    
    init(defaultSite : String, activeSites: [String]) {
        self.defaultSite = defaultSite
        self.defaultSitePlugin = NAME_TO_SITE_PLUGIN[defaultSite]!.init()
        
        var updatedSitePlugins = [self.defaultSitePlugin]
        for name in activeSites {
            if name != defaultSite {
                let plugin = NAME_TO_SITE_PLUGIN[name]!.init()
                updatedSitePlugins.append(plugin)
            }
        }
        self.activeSitePlugins = updatedSitePlugins
    }
}
