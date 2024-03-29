//
//  SearchResultsView.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/12/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var state: AppState
    @ObservedObject var setting: PluginSetting
    let statusBarHeight: CGFloat
    let searchBarNamespace: Namespace.ID
    
    @State private var showAlert = false
    @State private var keyboardHeight = 0.0
    
    var body: some View {
        UITableView.appearance().tableFooterView = UIView()
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { (notification: Notification) in
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    self.keyboardHeight = Double(keyboardRectangle.height)
                }
        })
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { (notification: Notification) in
                self.keyboardHeight = 0
            })
        return NavigationView {
            VStack {
                SearchBar(
                    statusBarHeight: statusBarHeight,
                    plugin: state.setting.defaultSitePlugin,
                    onCommit: {(name: String, location: String) -> Void in
                        if name == "" {
                            self.showAlert = true
                            return
                        }
                        self.state.onSearchButtonClicked(with: name, location: location)
                    },
                    onClose: {
                        logMessage("Closing search view")
                        self.state.isPlaceSearchLoading = false
                        self.state.placeSearchResults = [PlaceHolderModel]()
                        self.state.currentView = DionysusView.none
                    }
                ).matchedGeometryEffect(
                    id: "searchBarId",
                    in: searchBarNamespace
                )
                if state.isPlaceSearchLoading {
                    HStack {
                        ActivityIndicator()
                        Text("Looking up your places...")
                    }.padding()
                    Spacer()
                } else if isNonEmptyString(state.placeSearchLoadError) {
                    Text(state.placeSearchLoadError).padding()
                    Spacer()
                } else {
                    List(self.state.placeSearchResults) { result in
                        NavigationLink(destination:
                            PlaceView(placeHolder: result)
                        ) {
                            PlaceRow(
                                place: result.defaultPlaceInfoLoader.place!,
                                pluginName: result.defaultPlaceInfoLoader.plugin.name
                            )
                        }
                    }
                    .listStyle(.inset)
                    .onAppear {
                        if (self.state.placeSearchResults.count > 0) {
                            let pluginDisplayed = self.state.placeSearchResults[0].defaultPlaceInfoLoader.plugin
                            if (pluginDisplayed.name != state.setting.defaultSitePlugin.name) {
                                self.state.placeSearchResults = [PlaceHolderModel]()
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Please enter a search term to continue."))
        })
    }
}

struct SearchView_Previews: PreviewProvider {
    @Namespace static var ns
    static var previews: some View {
        SearchView(
            state: previewState,
            setting: previewState.setting,
            statusBarHeight: 20,
            searchBarNamespace: ns
        )
    }
}
