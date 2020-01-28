//
//  SearchBar.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/12/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

class UISearchFieldDelegate : UIViewController, UITextFieldDelegate {
    var onCommit: (()->())?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let f = onCommit {
            f()
        }
        return true
    }
}

struct SearchField : UIViewRepresentable {
    @Binding var isActive: Bool
    var placeholder: String
    var text: Binding<String>
    
    let onCommit: ()->()
    let delegate = UISearchFieldDelegate()
    
    func makeUIView(context: UIViewRepresentableContext<SearchField>) -> UITextField {
        delegate.onCommit = onCommit
        
        let field = UITextField()
        field.delegate = delegate
        field.placeholder = placeholder
        field.text = text.wrappedValue
        field.autocorrectionType = UITextAutocorrectionType.no
        field.returnKeyType = UIReturnKeyType.search
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: field, queue: OperationQueue.main, using: {(notification: Notification) in
            self.isActive = true
        })
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: field, queue: OperationQueue.main, using: {(notification: Notification) in
            self.isActive = false
        })
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: field, queue: OperationQueue.main, using: _searchFieldDidChange)
        return field
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<SearchField>) {
        uiView.text = text.wrappedValue
    }
    
    func _searchFieldDidChange(notification: Notification) {
        let newField = notification.object as! UITextField
        text.wrappedValue = newField.text ?? ""
    }
    
    typealias UIViewType = UITextField
}

struct SearchBar: View {
    @State var name = ""
    @State var location = ""
    @State private var isNameSearchFieldActive = false
    @State private var isLocationSearchFieldActive = false
    
    let statusBarHeight: CGFloat
    let onCommit: (String, String)->()
    
    func onCommitWithNameAndLocation() {
        onCommit(name, location)
    }
    
    var body: some View {
        let nameSearchField = SearchField(
            isActive: $isNameSearchFieldActive,
            placeholder: "Enter name",
            text: $name,
            onCommit: onCommitWithNameAndLocation
        )
        let locationSearchField = SearchField(
            isActive: $isLocationSearchFieldActive,
            placeholder: "Near me",
            text: $location,
            onCommit: onCommitWithNameAndLocation
        )
        
        return HStack(alignment: .firstTextBaseline) {
            Button(action: {
                // TODO:Go back to root view
                self.name = ""
                self.location = ""
                nameSearchField.text.wrappedValue = ""
                locationSearchField.text.wrappedValue = ""
            }) {
                Image(systemName: "xmark")
                    .padding(.leading)
            }.foregroundColor(.white)
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20.0)
                        .foregroundColor(isNameSearchFieldActive ? .orange : .gray)
                    nameSearchField
                    if isNameSearchFieldActive {
                        Button(action: {
                            self.name = ""
                            nameSearchField.text.wrappedValue = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(COLOR_LIGHT_GRAY)
                                .frame(width: 20.0)
                        }
                    }
                }
                .padding(3.0)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white, lineWidth: 5)
                )
                HStack {
                    Image(systemName: "mappin")
                        .frame(width: 20.0)
                        .foregroundColor(locationSearchField.isActive ? .orange : .gray)
                    locationSearchField
                    if isLocationSearchFieldActive {
                        Button(action: {
                            self.location = ""
                            locationSearchField.text.wrappedValue = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(COLOR_LIGHT_GRAY)
                                .frame(width: 20.0)
                        }
                    }
                }
                .padding(3.0)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white, lineWidth: 5)
                )
            }
            .padding(.horizontal)
        }
        .padding(.top, statusBarHeight + 15)
        .padding(.bottom, 15)
        .frame(height: 80.0 + statusBarHeight)
        .background(Color.gray)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(statusBarHeight: 20, onCommit:{_,_ in logMessage("Previewing search bar")})
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
