//
//  SearchBar.swift
//  Dyonisus
//
//  Created by Ginny Huang on 1/12/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

class UISearchFieldDelegate : UIViewController, UITextFieldDelegate {
    var onCommit: (()->())?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (onCommit != nil) {
            onCommit!()
        }
        return true
    }
}

struct SearchField : UIViewRepresentable {
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
        field.clearsOnBeginEditing = true
        field.autocorrectionType = UITextAutocorrectionType.no
        field.returnKeyType = UIReturnKeyType.search
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
    
    let statusBarHeight: CGFloat
    let onCommit: (String, String)->()
    
    func onCommitWithNameAndLocation() {
        onCommit(name, location)
    }
    
    var body: some View {
        let nameSearchField = SearchField(
            placeholder: "Enter name",
            text: $name,
            onCommit: onCommitWithNameAndLocation
        )
        let locationSearchField = SearchField(
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
                        .foregroundColor(.gray)
                    nameSearchField
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
                        .foregroundColor(.gray)
                    locationSearchField
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
        .padding(.top, statusBarHeight + 5)
        .padding(.bottom, 20)
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
