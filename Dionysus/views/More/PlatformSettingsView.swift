//
//  PlatformSettingsView.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/5/22.
//  Copyright © 2022 Ginny Huang. All rights reserved.
//

import SwiftUI

struct MakeDefaultButton: View {
    var body: some View {
        Button("Make Default") {
            print("This is default now")
        }
    }
}

struct PlatformSettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Default Platform")) {
                Text("google")
            }
            Section(header: Text("Active Platforms")) {
                ForEach(0..<3) { platform in
                    if #available(iOS 15.0, *) {
                        Text("Yelp").swipeActions(edge: .trailing) {
                            MakeDefaultButton().tint(COLOR_THEME_ORANGE)
                        }
                    } else {
                        Menu {
                            MakeDefaultButton()
                        } label: {
                            Text("Yelp")
                        }
                    }
                    
                }
            }
            // We don't have enough platforms yet so let's just make every platform active
            /*Section(header: Text("Other Platforms")) {
                
            }*/
        }
        .listStyle(.grouped)
        .navigationTitle("Platform Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PlatformSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PlatformSettingsView()
    }
}
