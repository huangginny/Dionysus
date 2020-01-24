//
//  SearchResultsView.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/12/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI
import Combine

struct SearchView: View {
    @ObservedObject var state: AppState
    @State private var showAlert = false
    
    let statusBarHeight: CGFloat
    
    var body: some View {
        UITableView.appearance().tableFooterView = UIView()
        return NavigationView {
            VStack {
                SearchBar(
                    statusBarHeight: statusBarHeight,
                    onCommit: {(name: String, location: String) -> Void in
                        if name == "" {
                            self.showAlert = true
                            return
                        }
                        self.state.onSearchButtonClicked(with: name, location: location)
                    }
                )
                if state.isLoading {
                    HStack {
                        ActivityIndicator()
                        Text("Looking up your places...")
                    }.padding()
                    Spacer()
                } else if isNonEmptyString(state.loadError) {
                    Text(state.loadError).padding()
                    Spacer()
                } else {
                    List(self.state.placeSearchResults) { result in
                        NavigationLink(destination:
                            PlaceView(
                                placeHolder: PlaceHolderModel(
                                    with: result,
                                    plugin: self.state.pluginOfPlaceSearchResults!,
                                    setting: self.state.setting
                            ))
                        ) {
                            PlaceRow(place: result)
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
    static var previews: some View {
        SearchView(state: previewState, statusBarHeight: 20)
    }
}
