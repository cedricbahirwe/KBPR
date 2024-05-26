//
//  SignUpScreen.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 20/04/2024.
//

import SwiftUI
import PhotosUI

struct SignUpModel: Encodable {
    var username = ""
    var email = ""
    var password = ""
    var firstName = ""
    var lastName = ""
    var badgeNumber = ""
    var phoneNumber: String?
    var profilePic: String?
    
    static let example = SignUpModel(username: "driosman", email: "newone@gmail.com", password: "driosman", firstName: "Drios", lastName: "Man", badgeNumber: "Drios1234", phoneNumber: "0782628000")
    
    static let example1 = SignUpModel(username: "intime", email: "intime@gmail.com", password: "intime", firstName: "Intime", lastName: "Innie", badgeNumber: "Innie123", phoneNumber: "0792828000")
}

struct SignUpScreen: View {
    @Binding var navPath: [AuthRoute]
    @AppStorage(.authRecentScreen) private var authRecentScreen: AuthRoute?
    
    @EnvironmentObject var authVM: AuthenticationStore
    
    @State private var registerModel = SignUpModel.example1
    @State private var isSignUp = false
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    
    @State private var isUploadingPic = false
    @State private var uploadProgress = 0.0
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(.signupHeader)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            
            VStack(spacing: 30) {
                
                Image(.signupHeader)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .hidden()
                
                
                VStack(spacing: 20) {
                    VStack {
                        ZStack {
                            if let avatarImage {
                                Image(uiImage: avatarImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(.regularMaterial, in: .circle)
                        .clipShape(.circle)
                        
                        
                        PhotosPicker("Choose Picture", selection: $avatarItem, matching: .images)

                    }
                    
                    NewUserFormView(registerModel: $registerModel)
                }
                .padding()
                
                
                Button(action: {
                    performRegistration()
                }, label: {
                    Label("Sign Up", systemImage: "arrow.forward.circle.fill")
                        .font(.largeTitle)
                        .bold()
                        .labelStyle(.titleThenIcon)
                })
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           
            
            ActivityIndicator(isVisible: authVM.isLoading, interactive: true)
            
            if isUploadingPic {
                VStack {
                    Text("Uploading your profile picture")
                    ProgressView.init("", value: uploadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                }
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                .frame(maxHeight: .infinity)
                .padding()
            }
        }
        .background {
            Color.white.onTapGesture(perform: hideKeyboard)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    navPath.append(.signIn)
                } label: {
                    Image(.signinBtn)
                }
                .buttonStyle(.unhighlighted)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: avatarItem) {
            Task {
                if let loaded = try? await avatarItem?.loadTransferable(type: Data.self) {
                    avatarImage = .init(data: loaded)
                }
            }
        }
    }
    
//    private func uploadProfilePicture() {
//        Task {
//            guard let avatarImage else { return }
//            isUploadingPic = true
//            
//            let imagePath = try await KBFBStorage.shared.uploadImage(avatarImage)
//            
//            isUploadingPic = false
//        }
//    }
    
    private func performRegistration() {
        Task {
            
            do {
                if let avatarImage  {
                    isUploadingPic = true
                    
                    let imagePath = try await KBFBStorage.shared.uploadImage(avatarImage, path: .profiles, progressHandler: { progress in
                        withAnimation {
                            uploadProgress = progress.fractionCompleted
                        }
                    })
                    
                    registerModel.profilePic = imagePath
                    
                    isUploadingPic = false
                    uploadProgress = 0.0
                }
            } catch {
                isUploadingPic = false
                uploadProgress = 0.0
            }
            
            do {
                let user = try await authVM.registerNewUser(registerModel)
                
                try LocalStorage.saveAUser(user)
                let destination = AuthRoute.verification(user: user)
                authRecentScreen = destination
                navPath = [destination]
            } catch {
                print("Not User Registered")
//                self.alerm
            }
        }
    }
}

#Preview {
    SignUpScreen(navPath: .constant([]))
        .environmentObject(AuthenticationStore())
}



struct ActivityIndicator: View {
    var isVisible: Bool
    var interactive: Bool
    var body: some View {
        Group {
            if isVisible && !interactive {
                Color.black.opacity(0.005)
            }
            if isVisible {
                ProgressView()
                    .padding(25)
                    .background(.thinMaterial, in: .rect(cornerRadius: 15))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                EmptyView()
            }
        }
        
    }
}

struct NewUserFormView: View {
    @Binding var registerModel: SignUpModel
    @FocusState var focusField: FieldFocus?
    
    enum FieldFocus: Int {
        case username, email, password, firstName, lastName, badgeNumber, phoneNumber
        
        func next() -> FieldFocus? {
            FieldFocus(rawValue: rawValue + 1)
        }
    }
    var body: some View {
        VStack(spacing: 12) {
            
            KBField("Username", text: $registerModel.username)
                .focused($focusField, equals: .username)
            
            KBField("Email", text: $registerModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .focused($focusField, equals: .email)
            
            KBField("Password", text: $registerModel.password)
                .focused($focusField, equals: .password)
            
            HStack {
                KBField("First Name", text: $registerModel.firstName)
                    .focused($focusField, equals: .firstName)
                
                KBField("Last Name", text: $registerModel.lastName)
                    .focused($focusField, equals: .lastName)
                
            }
            
            HStack {
                
                KBField("Badge Number", text: $registerModel.badgeNumber)
                    .focused($focusField, equals: .badgeNumber)
                
                KBField(
                    "Phone Number",
                    text: Binding(get: {
                        registerModel.phoneNumber ?? ""
                    }, set: { newValue in
                        let cleanNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        registerModel.phoneNumber = cleanNumber.isEmpty ? nil : cleanNumber
                    })
                )
                .keyboardType(.phonePad)
                .focused($focusField, equals: .phoneNumber)
            }
        }
        .submitLabel(focusField == .phoneNumber ? .done : .next)
        .onSubmit {
            focusField = focusField?.next()
        }
    }
}
