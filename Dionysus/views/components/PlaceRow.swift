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
    var body: some View {
        HStack {
            if isNonEmptyString(place.imageUrl) {
                URLImage(withURL: place.imageUrl!)
                    .frame(width: 50, height: 50)
            }
            VStack {
                HStack {
                    Text(place.name).lineLimit(1)
                    Spacer()
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
            }
        }
    }
}

struct PlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlaceRow(place: cupboard)
            PlaceRow(place: ootp)
        }
        .previewLayout(.fixed(width:300, height:50))
    }
}
