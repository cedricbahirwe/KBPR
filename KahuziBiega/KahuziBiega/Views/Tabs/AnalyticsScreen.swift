//
//  AnalyticsScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct AnalyticsScreen: View {
    var body: some View {
        VStack {
            Text("Analytics Screen")
            
            FlippableView()
        }
    }
}

#Preview {
    AnalyticsScreen()
}

import SwiftUI

struct FlippableView: View {
    @State private var isFlipped = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if !isFlipped {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 200, height: 200)
                        .overlay(content: {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Color.red
                                    Color.green
                                }
                                HStack(spacing: 0) {
                                    Color.blue
                                    Color.black
                                }
                            }
                        })
                        .cornerRadius(20)
                        .rotation3DEffect(
                            .degrees(0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                } else {
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 200, height: 200)
                        .overlay(content: {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Color.orange
                                    Color.yellow
                                }
                                HStack(spacing: 0) {
                                    Color.purple
                                    Color.teal
                                }
                            }
                        })
                        .cornerRadius(20)

                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
            }
            .scaleEffect(x: isFlipped ? -1 : 1, y: 1, anchor: .center) // Flip horizontally from center
            
            Spacer()
            
            Button("Flip") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isFlipped.toggle()
                }
            }
            
            Spacer()
        }
    }
}

