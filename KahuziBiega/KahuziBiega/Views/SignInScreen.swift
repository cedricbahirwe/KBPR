//
//  SignInScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 21/04/2024.
//

import SwiftUI

struct SignInScreen: View {
    var body: some View {
        VStack {
            Image(.signinHeader)
                .resizable()
                .scaledToFit()
            //                .background(Color.red)
                .overlay(alignment: .bottomLeading) {
                    Image(.signinLabel)
                        .padding()
                }
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                KBField("Phone Number", text: .constant(""), contentType: .telephoneNumber)
                
                KBField("Password ", text: .constant(""), contentType: .password)
                
                Button(action: {
                    print("Signing Up")
                }, label: {
                    Label("Sign In", systemImage: "arrow.forward.circle.fill")
                        .font(.largeTitle)
                        .bold()
                        .labelStyle(.titleThenIcon)
                })
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .padding(20)
            .background(.background.opacity(0.6))
            .clipShape(.rect(cornerRadius: 25.0))
            .overlay {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(
                        Color(red: 222/255, green: 225/255, blue: 231/255)
                        , lineWidth: 2
                    )
                    
            }
            
            .padding(20)
            
            
            Spacer()
        }
        .background(
            Image(.authBackground)
                .resizable()
                .ignoresSafeArea()
        )
//        .frame(maxWidth: .infinity)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    print("Signing Up")
                } label: {
                    Image(.signupBtn)
                }
                .buttonStyle(.unhighlighted)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SignInScreen()
}
