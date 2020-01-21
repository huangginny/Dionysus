//
//  PlaceView.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/15/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct Info: View {
    let imageName : String
    let infoString : String
    var body: some View {
        HStack {
            Image(systemName: imageName).frame(width: 20.0)
            Text(infoString)
            Spacer()
        }
        .padding([.top, .leading, .trailing])
    }
}

struct PlaceView: View {
    @ObservedObject var placeHolder : PlaceHolderModel
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing:0) {
                        URLImage(withURL: self.placeHolder.defaultPlace.imageUrl).frame(width: geometry.size.width, height:240)
                        Info(
                            imageName: "mappin.and.ellipse",
                            infoString: self.placeHolder.defaultPlace.formattedAddress
                        )
                        Info(
                            imageName: "clock",
                            infoString: self.placeHolder.defaultPlace.hours
                        )
                        Info(
                            imageName: "list.bullet.below.rectangle",
                            infoString: self.placeHolder.defaultPlace.categories.joined(separator: ", ")
                        )
                        ForEach([
                            InfoLoader(plugin: previewPlugin, place: self.placeHolder.defaultPlace),
                            InfoLoader(plugin: previewPlugin, place: nil), // FIXME
                        ], id: \.id) { loader in
                            RatingCard(loader:loader)
                        }
                        Spacer()
                    }.frame(width: geometry.size.width)
                }
            }
        }
        .navigationBarHidden(false)
        .navigationBarTitle(placeHolder.defaultPlace.name)
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView(placeHolder: cupboards)
    }
}
