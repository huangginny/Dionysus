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
            Text(place.name)
                .padding(.leading)
                .lineLimit(1)
                .layoutPriority(1)
            Text(place.formattedAddress.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(.gray)
                .lineLimit(1)
            Spacer()
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
