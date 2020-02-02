//
//  RatingCard.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/15/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct ScoreBar: View {
    let percentage : Double
    let color : Color
    
    let strokeTemplate = RoundedRectangle(cornerRadius: 10, style: .continuous)
    
    func getStrokeForPercentage(cuePoint: Double) -> some View {
        if cuePoint > self.percentage {
            return AnyView(strokeTemplate.fill(COLOR_LIGHT_GRAY))
        } else if cuePoint + 20 <= percentage {
            return AnyView(strokeTemplate.fill(color))
        } else {
            let location = (self.percentage - cuePoint) / 20
            return AnyView(strokeTemplate.fill(
                LinearGradient(
                    gradient: .init(stops: [
                        Gradient.Stop(color: color, location: CGFloat(location)),
                        Gradient.Stop(color: COLOR_LIGHT_GRAY, location: CGFloat(location))
                    ]),
                    startPoint: .init(x: 0, y: 1),
                    endPoint: .init(x: 1, y: 1)
                )
            ))
        }
    }
    
    var body: some View {
        HStack(spacing:1) {
            ForEach([0,20,40,60,80], id: \.self) { cuePoint in
                self.getStrokeForPercentage(cuePoint: cuePoint).frame(height:20)
            }
        }
    }
}

struct YelpScoreBar: View {
    let score : Double
    
    func getImageAssetName() -> String {
        switch score {
        case 5.0...:
            return "regular_5"
        case 4.5 ..< 5.0:
            return "regular_4_half"
        case 4.0 ..< 4.5:
            return "regular_4"
        case 3.5 ..< 4.0:
            return "regular_3_half"
        case 3.0 ..< 3.5:
            return "regular_3"
        case 2.5 ..< 3.0:
            return "regular_2_half"
        case 2.0 ..< 2.5:
            return "regular_2"
        case 1.5 ..< 2.0:
            return "regular_1_half"
        default:
            return "regular_1"
        }
    }
    
    var body: some View {
        Image(getImageAssetName()).resizable().aspectRatio(contentMode: .fit)
    }
}

struct RatingCard: View {
    let horizontalPadding = CGFloat(10)
    let loader : InfoLoader
    @State var visiblePercentage = 0.0
    
    func getColor() -> Color {
        let actualPercentage = self.loader.place!.score! / Double(self.loader.plugin.totalScore) * 100
        if loader.place == nil {
            return COLOR_LIGHT_GRAY
        }
        switch actualPercentage {
        case 90...:
            return getColorFromHex("#43603a")
        case 80..<90:
            return getColorFromHex("#52703d")
        case 70..<80:
            return getColorFromHex("#759444")
        case 60..<70:
            return getColorFromHex("#94b654")
        case 50..<60:
            return getColorFromHex("#98c475")
        case 40..<50:
            return getColorFromHex("#8fc6a0")
        case 30..<40:
            return getColorFromHex("#8ec5b8")
        case 20..<30:
            return getColorFromHex("#b3c1c0")
        default:
            return getColorFromHex("#c0c0c0")
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            if loader.isLoading {
                // Loading
                ActivityIndicator().padding(.leading, horizontalPadding)
                if !loader.plugin.attributionHasText {
                    Text("Loading place...")
                }
                Image(loader.plugin.attribution)
            } else if loader.message != "" {
                // Place does not exist or has no score
                if loader.plugin.attributionHasText {
                    VStack {
                        Text(loader.message)
                        Image(loader.plugin.attribution).padding(.trailing)
                    }
                } else {
                    HStack {
                        Spacer()
                        Text(loader.message)
                        Spacer()
                        Image(loader.plugin.attribution).padding(.trailing)
                    }
                }
            } else {
                // Exising rating with score
                HStack(alignment: .bottom, spacing:0) {
                    Text("\(Int(round(visiblePercentage)))")
                        .font(
                            .init(Font.system(
                                size: 48, weight: .regular, design: .default
                        )))
                        .lineLimit(1)
                    Text("%")
                        .font(
                            .init(Font.system(
                                size: 22, weight: .light, design: .default
                        )))
                        .lineLimit(1)
                }
                .foregroundColor(getColor())
                .frame(width:100)
                .padding(.leading, horizontalPadding)
                VStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        if loader.plugin.name == "Yelp" {
                            YelpScoreBar(score: loader.place!.score!).padding(.bottom, 5)
                        } else if visiblePercentage > 0 {
                            ScoreBar(
                                percentage: visiblePercentage,
                                color: getColorFromHex(loader.plugin.colorCode)
                            ).padding(.bottom, 10)
                        }
                        HStack(spacing:0) {
                            Text("\(String(format: "%.1f", loader.place!.score!)) " +
                                "/ \(loader.plugin.totalScore)").fontWeight(.semibold)
                            Text(" by \(loader.place!.numOfScores!) user" +
                            (loader.place!.numOfScores! > 1 ? "s" : ""))
                            Spacer()
                            Text("·")
                            Spacer()
                            Text(String(repeating: "$", count: loader.place!.price))
                                .font(.callout)
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        Spacer()
                    }
                    Divider()
                    Spacer()
                    HStack(alignment: .center) {
                        if !self.loader.plugin.attributionHasText {
                            Text("Powered by").font(.callout)
                        }
                        Image(self.loader.plugin.attribution)
                            .aspectRatio(contentMode: .fit)
                    }
                    .padding(.bottom)
                    .frame(maxHeight:30)
                }
                .padding(.horizontal, horizontalPadding)
                .onAppear {
                    let actualPercentage = self.loader.place!.score! / Double(self.loader.plugin.totalScore) * 100
                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                        self.visiblePercentage = min(self.visiblePercentage + 1, actualPercentage)
                        if (self.visiblePercentage >= actualPercentage) {
                            timer.invalidate()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onTapGesture {
            if let urlString = self.loader.place?.url {
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url)
            }
        }
        .frame(height:160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: COLOR_LIGHT_GRAY, radius: 20)
                .padding()
        )
    }
}

struct RatingCard_Previews: PreviewProvider {
    
    static var previews: some View {
        unrated.isLoading = false
        unrated.message = "I am unrated"
        rated.isLoading = false
        return VStack {
            RatingCard(loader: InfoLoader(plugin: mockSetting.defaultSitePlugin, place: nil))
            RatingCard(loader: rated)
            RatingCard(loader: unrated)
        }
        //.previewLayout(.fixed(width:375, height:100))
    }
}
