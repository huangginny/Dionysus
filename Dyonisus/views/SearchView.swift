//
//  SearchResultsView.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/12/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI
import Combine

struct MyIdentifiable: Identifiable {
    let id: String
}

struct SearchView: View {
    @ObservedObject var state: AppState
    
    let statusBarHeight: CGFloat
    
    var body: some View {
        UITableView.appearance().tableFooterView = UIView()
        return NavigationView {
            VStack {
                SearchBar(
                    statusBarHeight: statusBarHeight,
                    onCommit: self.state.onSearchButtonClicked
                )
                if state.isLoading {
                    Text("Loading, please wait")
                    Spacer()
                } else {
                    List(self.state.placeSearchResults) { result in
                        NavigationLink(destination:
                            PlaceView(
                                placeHolder: PlaceHolderModel(
                                    with: result,
                                    plugin: self.state.pluginOfPlaceSearchResults!,
                                    activeSitePlugins: self.state.setting.activeSitePlugins
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
        //.edgesIgnoringSafeArea(.top)
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(state: previewState, statusBarHeight: 20)
    }
}
