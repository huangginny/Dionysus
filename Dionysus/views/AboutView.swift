//
//  AboutView.swift
//  Dionysus
//
//  Created by Ginny Huang on 2/6/20.
//  Copyright © 2020 Ginny Huang. All rights reserved.
//

import SwiftUI
import MarkdownView

struct AboutView : UIViewRepresentable {
    
    @Binding var height : CGFloat
    
    func makeUIView(context: UIViewRepresentableContext<AboutView>) -> MarkdownView {
        logMessage("Start initializing markdown")
        let mdv = MarkdownView()
        mdv.isScrollEnabled = true
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
    
    func updateUIView(_ uiView: MarkdownView, context: UIViewRepresentableContext<AboutView>) {
        logMessage("")
    }
    
    typealias UIViewType = MarkdownView
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(height: .constant(900.0))
    }
}
