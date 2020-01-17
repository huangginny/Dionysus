//
//  PlaceView.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/15/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct PlaceView: View {
    @ObservedObject var placeHolder : PlaceHolderModel
    var body: some View {
        NavigationView {
            VStack {
                List([
                    InfoLoader(plugin: previewPlugin, place: placeHolder.defaultPlace),
                    InfoLoader(plugin: previewPlugin, place: nil) // FIXME
                ]) {
                    loader in RatingCard(loader:loader)
                }
            }
        }.navigationBarTitle(placeHolder.defaultPlace.name)
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView(placeHolder: cupboards)
    }
}
