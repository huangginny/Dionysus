//
//  DiceView.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/4/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct DiceView: View {
    @ObservedObject var state: AppState
    @State var label = "God is still making a decision..."
    @State var diceNumber = 1
    @State var diceColor = Color("tintColor")
    @State var timeElapsed = 0.0
    var body: some View {
        VStack(spacing:0) {
            HStack {
                Button(action: {
                    logMessage("Closing dice view")
                    self.state.diceResult = nil
                    self.state.diceRollError = ""
                    self.state.isDiceRolling = false
                    self.state.currentView = DionysusView.none
                }) {
                    Image(systemName: "xmark")
                }
                Spacer()
                Text(label).font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .frame(width: CGFloat(getScreenWidth()), height:50)
            Divider()
            if state.isDiceRolling {
                Spacer()
                if self.timeElapsed >= DICE_TIMEOUT_VALUE {
                    ActivityIndicator()
                } else {
                    Text("\(diceNumber)")
                        .font(
                            .init(Font.system(
                                size: 96, weight: .regular, design: .default
                        )))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(diceColor)
                                .padding()
                                .frame(width: 250, height: 250)
                        )
                        .onAppear {
                            if self.timeElapsed == 0 {
                                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                                    let idxNum = Int.random(in: 0 ..< 10)
                                    let idxCo = Int.random(in: 0 ..< 5)
                                    self.diceNumber = POWERS_OF_2[idxNum]
                                    self.diceColor = [COLOR_LIGHT_GRAY, COLOR_THEME_LIME, COLOR_THEME_GREEN, COLOR_THEME_ORANGE, COLOR_THEME_RED][idxCo]
                                    self.timeElapsed += 0.05
                                    if !self.state.isDiceRolling || self.timeElapsed >= DICE_TIMEOUT_VALUE {
                                        timer.invalidate()
                                    }
                                }
                            }
                        }
                }
                Spacer()
            } else if isNonEmptyString(state.diceRollError) {
                Spacer()
                Text(state.diceRollError)
                    .onAppear { self.label = "Error"}
                Spacer()
            } else if state.diceResult != nil {
                PlaceView(placeHolder: state.diceResult!)
                    .onAppear {
                        self.label = self.state.diceResult!.defaultPlaceInfoLoader.place!.name
                }
                Spacer()
            }
        }
    }
}

struct DiceView_Previews: PreviewProvider {
    static var previews: some View {
        DiceView(state:previewState)
    }
}
