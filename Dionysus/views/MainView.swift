//
//  MainView.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/3/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct MainViewButton: View {
    
    let label : String
    let action : ()->()
    
    var body: some View {
        Button(action: action) {
            Text(label).font(.title).padding(.vertical)
                .frame(width: 300, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground).opacity(0.7))
                        .shadow(color: Color(UIColor.systemBackground), radius: 20)
                        .padding()
                )
        }.padding(.vertical)
    }
}

struct MainView: View {
    @ObservedObject var state: AppState
    let statusBarHeight : CGFloat
        
    var body: some View {
        switch state.currentView {
        case .search:
            return AnyView(SearchView(
                state: self.state,
                statusBarHeight: self.statusBarHeight
            ))
        case .roll:
            return AnyView(
                DiceView(state: self.state)
            )
        default:
            return AnyView(VStack {
                Spacer()
                MainViewButton(label: "Search", action: {
                    self.state.currentView = DionysusView.search
                })
                MainViewButton(label: "Roll the Dice!", action: {
                    self.state.currentView = DionysusView.roll
                    self.state.isDiceRolling = true
                    self.state.onDiceRollClicked()
                })
                Spacer()
            }
            .background(
                Image("launchimage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.vertical)
            ))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(state: previewState, statusBarHeight: statusBarHeight)
    }
}
