//
//  SettingsModel.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/6/22.
//  Copyright © 2022 Ginny Huang. All rights reserved.
//

import Foundation
import Combine

class PluginSetting: ObservableObject {
    @Published var defaultSitePlugin : SitePlugin
    @Published var activeSitePlugins = [SitePlugin]()
    var defaultAndActivePlugins: [SitePlugin] {
        return [defaultSitePlugin] + activeSitePlugins
    }
    
    init(isMock: Bool) {
        var defaultSite: String?;
        if (isMock) {
            defaultSite = "Mock Plugin"
        } else {
            let standardUserDefault = UserDefaults.standard
            defaultSite = standardUserDefault.object(forKey: "defaultSite") as? String
            if (defaultSite == nil) {
                defaultSite = "Yelp"
                standardUserDefault.set(defaultSite, forKey: "defaultSite")
            }
        }
        self.defaultSitePlugin = NAME_TO_SITE_PLUGIN[defaultSite!]!.init()
        
        var updatedSitePlugins = [SitePlugin]()
        let activeSites = NAME_TO_SITE_PLUGIN.keys
        for name in activeSites {
            if name != defaultSite && name != "Mock Plugin" {
                let plugin = NAME_TO_SITE_PLUGIN[name]!.init()
                updatedSitePlugins.append(plugin)
            }
        }
        self.activeSitePlugins = updatedSitePlugins
    }
    
    convenience init() {
        self.init(isMock: false)
    }
    
    func updateDefaultSitePlugin(_ pluginName: String) {
        if (pluginName == self.defaultSitePlugin.name) {
            return
        }
        let eligibleKeys = self.defaultAndActivePlugins.map { $0.name }
        if (!eligibleKeys.contains(pluginName)) {
            return
        }
        
        var newDefaultPlugin = self.defaultSitePlugin;
        var newActivePlugins = [SitePlugin]()
        for plugin in self.defaultAndActivePlugins {
            if pluginName == plugin.name {
                newDefaultPlugin = plugin
            } else {
                newActivePlugins.append(plugin)
            }
        }
        self.defaultSitePlugin = newDefaultPlugin
        self.activeSitePlugins = newActivePlugins
        UserDefaults.standard.set(pluginName, forKey: "defaultSite")
    }
}
