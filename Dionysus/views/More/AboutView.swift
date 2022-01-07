//
//  AboutView.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/6/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI
import MarkdownView

struct SwiftUIMarkDownView : UIViewRepresentable {
    
    @Binding var height : CGFloat
    
    func makeUIView(context: UIViewRepresentableContext<SwiftUIMarkDownView>) -> MarkdownView {
        logMessage("Start initializing markdown")
        let mdv = MarkdownView()
        mdv.isScrollEnabled = false
        mdv.onTouchLink = { (request: URLRequest) -> Bool in
            if let url = request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return false
        }
        mdv.onRendered = {
            logMessage("Markdown text is rendered with instrinct height \($0)")
            self.height = $0
            mdv.superview?.frame.size.height = $0
            mdv.superview?.setNeedsLayout()
        }
        if let path = Bundle.main.path(forResource: "README", ofType: "md"),
            let text = try? String(contentsOfFile: path, encoding: .utf8) {
            mdv.load(markdown: text)
        }
        return mdv
    }
    
    func updateUIView(_ uiView: MarkdownView, context: UIViewRepresentableContext<SwiftUIMarkDownView>) {
        logMessage("")
    }
    
    typealias UIViewType = MarkdownView
}

struct AboutView : View {
    @Binding var height : CGFloat
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        let view = ScrollView {
            SwiftUIMarkDownView(height: $height)
                .padding(.top, 10)
                .navigationTitle("About Dionysus")
                .navigationBarTitleDisplayMode(.large)
        }
        if (colorScheme == .dark) {
            return AnyView(view.colorInvert())
        }
        return AnyView(view)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(height: .constant(900.0))
    }
}
