//
//  CachedImage.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import SwiftUI
 
struct CachedImage<Placeholder: View>: View {
    let data: Data?
    let url: URL?
    @ViewBuilder var placeholder: () -> Placeholder
 
    var body: some View {
        if let data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholder()
                }
            }
        }
    }
}
 
extension CachedImage where Placeholder == AnyView {
    init(data: Data?, url: URL?) {
        self.data = data
        self.url = url
        self.placeholder = { AnyView(Rectangle().fill(.quaternary)) }
    }
}
 
