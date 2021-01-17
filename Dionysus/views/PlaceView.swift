//
//  PlaceView.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/15/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI
import MapKit

struct Info: View {
    var place: PlaceInfoModel
    var size: CGSize
    var onTapAddress: () -> ()
    
    var body: some View {
        VStack {
            if place.categories.count > 0 {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "list.bullet.below.rectangle").frame(width: 20)
                    Text(place.categories.joined(separator: ", "))
                    Spacer()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "mappin.and.ellipse").frame(width: 20)
                Button(action: { self.onTapAddress() }) {
                    Text(place.formattedAddress.joined(separator: "\n"))
                }
                Spacer()
                if isNonEmptyString(getFormattedDistance(place.distance)) {
                    Text("(\(getFormattedDistance(place.distance)!))")
                }
            }
            if isNonEmptyString(place.phone) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "phone.fill").frame(width: 20.0)
                    Button(action: {
                        if let phoneNumber = getRawPhoneNumber(self.place.phone),
                            let phoneUrl = URL(string: "telprompt://\(phoneNumber)") {
                            UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text(place.phone!)
                    }
                    Spacer()
                }
            }
            if (place.permanently_closed == true || place.open_now != nil || isNonEmptyString(place.hours)) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName:  "clock").frame(width: 20)
                    if place.permanently_closed ?? false {
                        Text("Permanently closed").fontWeight(.bold).foregroundColor(.red)
                    } else {
                        if place.open_now != nil {
                            if place.open_now ?? false {
                                Text("Open").fontWeight(.bold).foregroundColor(.green)
                            } else {
                                Text("Closed").fontWeight(.bold).foregroundColor(.red)
                            }
                        }
                        if isNonEmptyString(place.hours) {
                            Text(place.hours!)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.8))
    }
}

struct PlaceView: View {
    @ObservedObject var placeHolder : PlaceHolderModel
    @State var searched = false
    
    var body: some View {
        GeometryReader { geoSafeArea in // https://stackoverflow.com/questions/64280447/scrollview-navigationview-animation-glitch-swiftui
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing:0) {
                        if self.placeHolder.loadComplete && isNonEmptyString(self.placeHolder.defaultPlaceInfoLoader.place?.imageUrl) {
                            URLImage(withURL: self.placeHolder.defaultPlaceInfoLoader.place!.imageUrl!)
                                .frame(width: geometry.size.width, height: CGFloat(PHOTO_HEIGHT), alignment: .top)
                        }
                        Info(
                            place: self.placeHolder.defaultPlaceInfoLoader.place!,
                            size: geometry.size,
                            onTapAddress: self.placeHolder.defaultPlaceInfoLoader.plugin.name == "Google" ?
                                {
                                    if let urlStr = self.placeHolder.defaultPlaceInfoLoader.place?.url,
                                        let url = URL(string: urlStr) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                } : {
                                    self.placeHolder.mapItem.openInMaps(launchOptions: nil)
                                }
                        )
                        RatingCard(loader: self.placeHolder.defaultPlaceInfoLoader)
                        ForEach(Array(self.placeHolder.infoForSite.values), id: \.id) { loader in
                            RatingCard(loader:loader)
                        }
                        .frame(width: geometry.size.width)
                    }
                    .padding(.top, geoSafeArea.safeAreaInsets.top)
                    .padding(.bottom, geoSafeArea.safeAreaInsets.bottom)
                    .padding(.leading, geoSafeArea.safeAreaInsets.leading)
                    .padding(.trailing, geoSafeArea.safeAreaInsets.trailing)
                }
            }
            .edgesIgnoringSafeArea(.all)
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
