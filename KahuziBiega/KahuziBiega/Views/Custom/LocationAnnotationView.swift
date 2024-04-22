//
//  LocationAnnotationView.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 22/04/2024.
//

import SwiftUI

struct LocationMapAnnotationView: View {
    let image: Image
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.marketBg)
                .overlay(alignment: .top) {
                    image
                        .resizable()
                        .clipShape(.circle)
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 3)
                        }
                        .frame(width: 72, height: 72)
                        .padding(.top, 10)
                }
            Image(.markerUnder)
                .offset(y: 22)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ZStack {
        Color.white.ignoresSafeArea()
        LocationMapAnnotationView(image: .init(.img2))
    }
}
