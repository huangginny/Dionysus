//
//  RatingCard.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/15/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct RatingCard: View {
    var loader : InfoLoader
    var body: some View {
        HStack {
            if loader.isLoading {
                Spacer()
                Text("Loading ...")
                Spacer()
                Text(loader.plugin.name)
            } else {
                Text("\(String(format: "%.1f", loader.place!.score))")
                Spacer()
                VStack {
                    HStack {
                        Text("-----------")
                        Spacer()
                        Text("Out of \(loader.plugin.totalScore)")
                    }
                    HStack {
                        Text("by \(loader.place!.numOfScores) users on \(loader.plugin.name)")
                    }
                }
            }
        }
    }
}

struct RatingCard_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RatingCard(loader: InfoLoader(plugin: previewPlugin, place: nil))
            RatingCard(loader: InfoLoader(
                plugin: previewPlugin,
                place: ootp)
            )
        }
        .previewLayout(.fixed(width:300, height:50))
    }
}
