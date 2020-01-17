//
//  RootView.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/11/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var state: AppState
    @State private var selection = 0
    
    let statusBarHeight : CGFloat
 
    var body: some View {
        let tabView = TabView(selection: $selection){
            SearchView(state: state, statusBarHeight: statusBarHeight)
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                }
                .tag(0)
            Text("Settings...")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
                .tag(1)
            Text("About Author")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
                }
                .tag(2)
        }
        if selection == 0 {
            return AnyView(tabView.edgesIgnoringSafeArea(.top))
        }
        return AnyView(tabView)
    }
}

let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
let previewState = AppState()
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(state: previewState, statusBarHeight: statusBarHeight)
        //.previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
