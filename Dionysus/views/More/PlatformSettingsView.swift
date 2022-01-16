//
//  PlatformSettingsView.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/5/22.
//  Copyright © 2022 Ginny Huang. All rights reserved.
//

import SwiftUI

let DEFAULT_PLATFORM_DESC = """
The default platform is used to search for places.
For example, if your default platform is Yelp, \
the list of search results would be provided by Yelp.
"""

struct PlatformSettingsCell: View {
    var plugin: SitePlugin
    var body: some View {
        HStack {
            URLImage(withURL: plugin.faviconUrl)
                .padding(.vertical, 5)
                .frame(width: 25, height: 25)
            Text(plugin.name)
        }
    }
}

struct MakeDefaultButton: View {
    var setting: PluginSetting
    var pluginName: String
    var body: some View {
        Button("Make Default") {
            setting.updateDefaultSitePlugin(pluginName)
        }
    }
}

struct PlatformSettingsView: View {
    @ObservedObject var setting: PluginSetting
    var body: some View {
        List {
            Section(
                header: Text("Default Platform"),
                footer: Text(DEFAULT_PLATFORM_DESC)
            ) {
                PlatformSettingsCell(plugin: setting.defaultSitePlugin)
            }
            Section(header: Text("Active Platforms")) {
                ForEach(
                    setting.activeSitePlugins.sorted(by: { $0.name < $1.name }),
                    id: \.name
                ) { plugin in
                    if #available(iOS 15.0, *) {
                        PlatformSettingsCell(plugin: plugin)
                            .swipeActions(edge: .trailing) {
                            MakeDefaultButton(
                                setting: setting,
                                pluginName: plugin.name
                            ).tint(COLOR_THEME_ORANGE)
                        }
                    } else {
                        Menu {
                            MakeDefaultButton(setting: setting, pluginName: plugin.name)
                        } label: {
                            PlatformSettingsCell(plugin: plugin)
                        }
                    }
                    
                }
            }
            /**
             TODO: We don't have enough platforms yet so let's just make every platform active
             Section(header: Text("Other Platforms")) {
            }
             */
        }
        .listStyle(.grouped)
        .navigationTitle("Platform Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PlatformSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PlatformSettingsView(setting: previewState.setting)
    }
}
