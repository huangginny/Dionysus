//
//  ActivityIndicator.swift
//  Dionysus
//
//  Created by Ginny Huang on 1/21/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let aiv = UIActivityIndicatorView()
        aiv.startAnimating()
        return aiv
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        // pass
    }
    
    typealias UIViewType = UIActivityIndicatorView
    
    
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
