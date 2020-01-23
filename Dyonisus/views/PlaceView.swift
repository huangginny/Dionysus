//
//  PlaceView.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/15/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct Info: View {
    var place: PlaceInfoModel
    var size: CGSize
    
    var body: some View {
        VStack {
            if place.imageUrl ?? "" != "" {
                URLImage(withURL: place.imageUrl!).frame(width: size.width, height: 240)
            }
            VStack {
                if place.categories != nil && place.categories!.count > 0 {
                    HStack {
                        Image(systemName: "list.bullet.below.rectangle").frame(width: 20)
                        ForEach(place.categories!, id:\.self) { category in
                            Text(category).background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(COLOR_LIGHT_GRAY)
                                        .padding(.horizontal, -7)
                            ).padding(.leading, 3)
                        }
                        Spacer()
                    }
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse").frame(width: 20)
                    Text(place.formattedAddress)
                    Spacer()
                }
                if place.phone != nil {
                    HStack {
                        Image(systemName: "phone.fill").frame(width: 20.0)
                        Text(place.phone!)
                        Spacer()
                    }
                }
                HStack {
                    if place.permanently_closed ?? false {
                        Text("Permanently closed").fontWeight(.bold).foregroundColor(.red)
                    } else {
                        if place.hours != nil && place.hours != "" {
                            Image(systemName:  "clock").frame(width: 20)
                            Text(place.hours!)
                        }
                        if place.open_now != nil {
                            if place.open_now ?? false {
                                Text("Open").fontWeight(.bold).foregroundColor(.green)
                            } else {
                                Text("Closed").fontWeight(.bold).foregroundColor(.red)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct PlaceView: View {
    @ObservedObject var placeHolder : PlaceHolderModel
    @State var searched = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            GeometryReader { geometry in
                VStack(spacing:0) {
                    Info(place: self.placeHolder.defaultPlaceInfoLoader.place!, size: geometry.size)
                    RatingCard(loader: self.placeHolder.defaultPlaceInfoLoader)
                    ForEach([
                        InfoLoader(plugin: previewPlugin, place: nil), // FIXME
                    ], id: \.id) { loader in
                        RatingCard(loader:loader)
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
        }
        .onAppear {
            if !self.searched {
                self.placeHolder.loadPlaces()
                self.searched = true
            }
        }
        .navigationBarTitle(placeHolder.defaultPlaceInfoLoader.place!.name)
        .navigationBarHidden(false)
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView(placeHolder: cupboards)
    }
}
