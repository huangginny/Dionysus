//
//  RatingCard.swift
//  Dyonisus
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
            return AnyView(strokeTemplate.fill(RatingCard.LIGHT_GRAY))
        } else if cuePoint + 20 <= percentage {
            return AnyView(strokeTemplate.fill(color))
        } else {
            let location = (self.percentage - cuePoint) / 20
            return AnyView(strokeTemplate.fill(
                LinearGradient(
                    gradient: .init(stops: [
                        Gradient.Stop(color: color, location: CGFloat(location)),
                        Gradient.Stop(color: RatingCard.LIGHT_GRAY, location: CGFloat(location))
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
                self.getStrokeForPercentage(cuePoint: cuePoint).frame(height:15)
            }
        }
    }
}

struct RatingCard: View {
    static let LIGHT_GRAY = Color(UIColor.lightGray)
    let horizontalPadding = CGFloat(10)
    var loader : InfoLoader
    @State var visiblePercentage = 0.0
    
    func getColor() -> Color {
        let actualPercentage = self.loader.place!.score / Double(self.loader.plugin.totalScore) * 100
        if loader.place == nil {
            return RatingCard.LIGHT_GRAY
        }
        switch actualPercentage {
        case 0...40:
            return Color.red
        case 40...60:
            return Color.orange
        case 60...80:
            return Color.yellow
        case 80...100:
            fallthrough
        default:
            return Color.green
        }
    }
    
    var body: some View {
        HStack {
            if loader.isLoading {
                // Loading
                Text("Loading rating from \(loader.plugin.name)...")
                    .padding(.leading, horizontalPadding)
                Spacer()
                Image(loader.plugin.logo).resizable()
                    .frame(width: 25, height: 25, alignment: .bottomTrailing)
                    .padding(.trailing, horizontalPadding)
            } else if loader.place == nil {
                // Place does not exist
                Text("This place has not yet been rated.").padding(.leading, horizontalPadding)
                    
                Spacer()
                Image(loader.plugin.logo).resizable()
                    .frame(width: 25, height: 25, alignment: .bottomTrailing)
                    .padding(.trailing, horizontalPadding)
            } else {
                // Exising rating with score
                HStack(alignment: .bottom, spacing:0) {
                    Text("\(String(format: "%.1f", loader.place!.score))").font(.init(Font.system(size: 48, weight: .regular, design: .default)))
                        .lineLimit(1)
                    Text("/\(String(loader.plugin.totalScore))").lineLimit(1)
                }
                .foregroundColor(getColor())
                .frame(width:100)
                .padding(.leading, horizontalPadding)
                VStack {
                    Spacer()
                    HStack {
                        if visiblePercentage > 0 {
                            ScoreBar(percentage: visiblePercentage, color: getColor())
                        }
                        HStack(spacing:0) {
                            Spacer()
                            Text(String(repeating: "$", count: loader.place!.price))
                            .padding(0)
                        }
                        .frame(width: 60)
                    }.onAppear {
                        let actualPercentage = self.loader.place!.score / Double(self.loader.plugin.totalScore) * 100
                        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                            self.visiblePercentage = min(self.visiblePercentage + 1, actualPercentage)
                            if (self.visiblePercentage >= actualPercentage) {
                                timer.invalidate()
                            }
                        }
                    }
                    Spacer()
                    Divider()
                    HStack {
                        Text("by \(loader.place!.numOfScores) user\(loader.place!.numOfScores > 1 ? "s" : "") on")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(loader.plugin.logo).resizable().frame(width: 25, height: 25, alignment: .bottomTrailing)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
        .padding()
        .onTapGesture {
            if let urlString = self.loader.place?.url {
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url)
            }
        }
        .frame(height:150)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: RatingCard.LIGHT_GRAY, radius: 5)
                .padding()
        )
    }
}

struct RatingCard_Previews: PreviewProvider {
    
    static var previews: some View {
        unrated.isLoading = false
        return VStack {
            RatingCard(loader: InfoLoader(plugin: previewPlugin, place: nil))
            RatingCard(loader: InfoLoader(
                plugin: previewPlugin,
                place: ootp)
            )
            RatingCard(loader:unrated)
        }
        //.previewLayout(.fixed(width:375, height:100))
    }
}
