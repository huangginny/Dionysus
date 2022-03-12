//
//  MainView.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/3/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct SearchBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct DiceButton: View {
    @ObservedObject var state: AppState
    let icon : String
    let label : String
    let category : Category
    let length = (UIScreen.main.bounds.width - 40) / 3
    var body: some View {
        Button(action: {
            self.state.onDiceRollClicked(category: category)
        }) {
            VStack {
                Text(icon).font(.system(size: 50))
                Text(label).font(.footnote)
            }
        }
        .accentColor(Color(UIColor.darkGray))
        .frame(width: length, height: length)
    }
}

struct MainView: View {
    @ObservedObject var state: AppState
    let statusBarHeight : CGFloat
    @Namespace var searchBarNamesapce
        
    var body: some View {
        UINavigationBar.setAnimationsEnabled(false)
        switch state.currentView {
        case .search:
            return AnyView(SearchView(
                state: self.state,
                setting: self.state.setting,
                statusBarHeight: self.statusBarHeight,
                searchBarNamespace: searchBarNamesapce
            )).id("SearchView")
        case .roll:
            return AnyView(
                DiceView(state: self.state)
            ).id("DiceView")
        default:
            return AnyView(
                VStack {
                    Spacer()
                    Button(action:{
                        withAnimation(.linear(duration: 0.5)) {
                            self.state.currentView = DionysusView.search
                        }
                    }) {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "magnifyingglass").foregroundColor(COLOR_THEME_LIME)
                                Text("What can Dionysus get you?").foregroundColor(.gray)
                                Spacer()
                            }
                            .font(.title3)
                            .padding(25)
                            .frame(height:80)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.white))
                                    .shadow(color: Color(UIColor.systemGray), radius: 10)
                                    .padding(15)
                            )
                            .matchedGeometryEffect(id: "searchBarId", in: searchBarNamesapce)
                            Spacer()
                        }
                    }
                    .buttonStyle(SearchBarButtonStyle())
                    .background(
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .padding()
                            .edgesIgnoringSafeArea(.vertical)
                            .scaledToFill()
                    )
                    Spacer()
                    Text("or let Dionysus pick you a ...")
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.darkGray))
                    VStack(spacing:0) {
                        HStack(spacing:0) {
                            DiceButton(state: state, icon: "🥞", label: "Breakfast", category: .breakfast)
                            DiceButton(state: state, icon: "🍱", label: "Lunch", category: .lunch)
                            DiceButton(state: state, icon: "🍝", label: "Dinner", category: .dinner)
                        }
                        HStack(spacing:0) {
                            DiceButton(state: state, icon: "☕️", label: "Cafe", category: .cafe)
                            DiceButton(state: state, icon: "🍦", label: "Dessert", category: .dessert)
                            DiceButton(state: state, icon: "🍻", label: "Nightlife", category: .nightlife)
                        }
                    }
                    .frame(
                        height: (UIScreen.main.bounds.width - 40) * 2 / 3
                    )
                    .padding(.horizontal)
                    Button(action:{
                        self.state.onDiceRollClicked(category: .anything);
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "dice.fill")
                            Text("Dionysus's Lucky Place")
                            Spacer()
                        }
                    }
                    .accentColor(.white)
                    .padding(25)
                    .frame(height:80)
                    .background(
                        Rectangle()
                            .fill(COLOR_THEME_LIME)
                            .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                    )
                    .padding(.bottom)
                }
                .preferredColorScheme(.light)
            ).id("MainView")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(state: previewState, statusBarHeight: statusBarHeight)
    }
}
