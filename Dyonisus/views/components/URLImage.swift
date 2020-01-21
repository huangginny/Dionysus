//
//  URLImage.swift
//  Dyonisus
//
//  Reference: https://dev.to/gualtierofr/remote-images-in-swiftui-49jp
//

import SwiftUI

class ImageLoader: ObservableObject {
    @Published var dataIsValid = false
    var data: Data?

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.dataIsValid = true
                self.data = data
            }
        }
        task.resume()
    }
}

struct URLImage: View {
    @ObservedObject var imageLoader: ImageLoader
    
    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
    }
    
    func imageFromData(_ data:Data) -> UIImage {
        UIImage(data: data) ?? UIImage()
    }

    var body: some View {
        if imageLoader.dataIsValid {
            return AnyView(Image(uiImage: imageFromData(imageLoader.data!))
                .resizable()
                .aspectRatio(contentMode: .fill)
            )
        }
        return AnyView(EmptyView())
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(withURL: "https://vignette.wikia.nocookie.net/harrypotter/images/6/6f/HPDH1-1435.jpg")
    }
}
