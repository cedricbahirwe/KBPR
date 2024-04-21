//
//  HomeScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct HomeScreen: View {
    @Binding var navPath: [AppRoute]
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "dd MMM yyyy, h:mm a"
           return formatter
       }()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Illegal hunting activity near the Visitor Center Area")
                        .fontWeight(.semibold)
                    
                    Text("On the morning patrol, encountered a group of visitors near the Eastern Trail Area who had an unexpected ..")
                        .fontWeight(.light)
                    
                    HStack {
                        Text("Location: \(Text("Visitor Center Area").bold())")
                            .foregroundStyle(.accent)
                    }
                    
                    HStack {
                        
                        Group {
                            Label(dateFormatter.string(from: .now), systemImage: "calendar")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .padding(8)
                                .background(.tint.quinary.opacity(0.5), in: .rect(cornerRadius: 8))
                                .foregroundStyle(.accent)
                            
                            Spacer()
                            
                            Text("In Review")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .padding(8)
                                .background(.tint.quinary.opacity(0.5), in: .capsule)
                                .foregroundStyle(.accent)
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                
                Spacer()
                
            }
        }
        .safeAreaInset(edge: .top) {
            topBarView
                .background(.regularMaterial, ignoresSafeAreaEdges: .top)
        }
    }
}

#Preview {
    HomeScreen(navPath: .constant([]))
}

private extension HomeScreen {
    var topBarView: some View {
        HStack {
            HStack(spacing: 16) {
                Button(action: {
                    
                }) {
                    Image(.mapMarker)
                }
                Button(action: {}) {
                    Image(.siren)
                }
            }
            
            Text("Kauzi Biega Park")
                .bold()
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(.radioTower)
                }
                
                Button(action: {}) {
                    Image(.avatarImg)
                }
            }
        }
        .padding()
    }
}
