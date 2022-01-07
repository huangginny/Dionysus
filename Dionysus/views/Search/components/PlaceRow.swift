//
//  PlaceRow.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/12/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct PlaceRow: View {
    var place: PlaceInfoModel
    var pluginName: String
    var body: some View {
        HStack {
            if isNonEmptyString(place.imageUrl) {
                URLImage(withURL: place.imageUrl!)
                    .frame(width: 50, height: 50)
                    .clipped()
            }
            VStack(spacing:0) {
                HStack {
                    Text(place.name).lineLimit(1)
                    Spacer()
                    if place.score != nil {
                        if pluginName == "Yelp" {
                            Image(YelpPlugin.getImageAssetName(score: place.score!))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height:15)
                                .layoutPriority(1)
                        } else {
                            HStack {
                                Text("Rating:").font(.footnote)
                                Text("\(String(format: "%.1f", place.score!))")
                                    .fontWeight(.bold)
                                    .font(.callout)
                            }
                            .foregroundColor(Color(UIColor.systemBackground))
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("tintColor").opacity(0.7))
                            )
                        }
                    }
                }
                HStack {
                    Text(place.formattedAddress.joined(separator: ", "))
                        .font(.footnote)
                    Spacer()
                    if isNonEmptyString(getFormattedDistance(place.distance)){
                        Text(getFormattedDistance(place.distance)!)
                            .layoutPriority(1)
                            
                    }
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding(.top, 5)
            }
        }
    }
}

struct PlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlaceRow(place: cupboard, pluginName: "Mock Plugin")
            PlaceRow(place: ootp, pluginName: "Yelp")
        }
        .previewLayout(.fixed(width:300, height:50))
    }
}
