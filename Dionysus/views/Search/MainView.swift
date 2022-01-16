//
//  MainView.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/3/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

func buttonAction() {}

struct DiceButton: View {
    let icon : String
    let label : String
    let length : CGFloat
    var body: some View {
        VStack {
            Text(icon).font(.system(size: 50))
            Text(label).font(.footnote)
        }.frame(width: length, height: length)
    }
}

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
            return AnyView(
                GeometryReader { geometry in
                    VStack {
                        VStack {
                            Spacer()
                            Button(action:buttonAction) {
                                HStack {
                                    Image(systemName: "magnifyingglass").foregroundColor(COLOR_THEME_LIME)
                                    Text("What can Dionysus get you?").foregroundColor(.gray)
                                    Spacer()
                                }.font(.title3)
                            }
                            .padding(25)
                            .frame(height:80)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.white))
                                    .shadow(color: Color(UIColor.systemGray), radius: 10)
                                    .padding(15)
                            )
                            Spacer()
                        }.background(
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .padding()
                                .edgesIgnoringSafeArea(.vertical)
                                .scaledToFill()
                        )
                        VStack(spacing:0) {
                            Text("or let Dionysus pick you a ...").font(.footnote)
                            HStack(spacing:0) {
                                DiceButton(icon: "🥞", label: "Breakfast", length: geometry.size.width / 3 - 20)
                                DiceButton(icon: "🍱", label: "Lunch", length: geometry.size.width / 3 - 20)
                                DiceButton(icon: "🍲", label: "Dinner", length: geometry.size.width / 3 - 20)
                            }
                            HStack(spacing:0) {
                                DiceButton(icon: "☕️", label: "Cafe", length: geometry.size.width / 3 - 20)
                                DiceButton(icon: "🍦", label: "Dessert", length: geometry.size.width / 3 - 20)
                                DiceButton(icon: "🍻", label: "Nightlife", length: geometry.size.width / 3 - 20)
                            }
                        }
                        .frame(
                            height: geometry.size.width * 2 / 3
                        ).padding()
                        Button(action:buttonAction) {
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
                        Spacer()
                    }.preferredColorScheme(.light)
                }
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(state: previewState, statusBarHeight: statusBarHeight)
    }
}
