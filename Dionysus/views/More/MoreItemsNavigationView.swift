//
//  MoreItemsNavigationView.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/5/22.
//  Copyright © 2022 Ginny Huang. All rights reserved.
//

import SwiftUI

struct MoreItemsNavigationView: View {
    @ObservedObject var state: AppState
    @State var aboutViewHeight = UIScreen.main.bounds.height
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: PlatformSettingsView(setting: state.setting)) {
                    Text("Platform Settings")
                }
                NavigationLink(destination: AboutView(height: $aboutViewHeight)) {
                    Text("About Dionysus")
                }
            }
            .listStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:32)
                        Text("Dionysus").bold()
                    }
                }
            }
            .onAppear { UINavigationBar.setAnimationsEnabled(true) }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MoreItemsNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MoreItemsNavigationView(state: previewState)
    }
}
