//
//  KBImage.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/05/2024.
//

import SwiftUI

struct KBImage<PlaceholderView: View>: View {
    let placeholder: () -> PlaceholderView
    let imagePath: ImageStoragePath?
    @State private var imageData: Data?
    @State private var showIndicator: Bool = false
    @State private var isLoading: Bool = false
    
    
    init(_ imagePath: ImageStoragePath?,
         showIndicator: Bool = false
         @ViewBuilder placeholder: @escaping () -> PlaceholderView) {
        self.imagePath = imagePath
        self.showIndicator = showIndicator
        self.placeholder = placeholder
    }
    var body: some View {
        ZStack {
            if let imageData,
                let img =  UIImage(data: imageData) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
            }
            if showIndicator && isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .task(id: isLoading) {
            if let imagePath {
                isLoading = true
                self.imageData = await KBFBStorage.shared.getImageData(imagePath)
                isLoading = false
            }
        }
    }
}
