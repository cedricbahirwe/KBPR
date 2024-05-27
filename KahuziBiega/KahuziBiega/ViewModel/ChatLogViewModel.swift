//
//  ChatLogViewModel.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 27/05/2024.
//

import Foundation
import Firebase

import Combine

class ChatLogViewModel: ObservableObject {
    let scrollUpdate = PassthroughSubject<Int, Never>()
    @Published var chatText = ""
    
    var cleanMessage: String {
        chatText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var canSendMessage: Bool {
        !cleanMessage.isEmpty
    }
    
    // TODO: Add alert support
    @Published var errorMessage = ""
    
    @Published var chatMessages = [KBChatMessage]()
    
    @Published var chatUser: KBChatUser?
    
    init(chatUser: KBChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = KBFBManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = KBFBManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else { return }
                guard let querySnapshot else { return }
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot.documentChanges.enumerated().forEach({ index, change in
                    if change.type == .added {
                        do {
                            let cm = try change.document.data(as: KBChatMessage.self)
                            self.chatMessages.append(cm)
                            let changesCount = querySnapshot.documentChanges.count
                            if (index + 1 == changesCount) {
                                DispatchQueue.main.async {
                                    self.scrollUpdate.send(changesCount)
                                }
                            }
                            print("Appending chatMessage in ChatLogView", index)
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                })
            }
    }
    
    func sendMessage() {
        guard let senderId = KBFBManager.shared.auth.currentUser?.uid else { return }
        guard let receiverId = chatUser?.uid else { return }
        
        let document = KBFBManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(senderId)
            .collection(receiverId)
            .document()
        
        let message = KBChatMessage(id: nil, fromId: senderId, toId: receiverId, text: cleanMessage, timestamp: .now)
        
        try? document.setData(from: message) { [weak self] error in
            guard let self else { return }
            if let error  {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage(senderId: senderId, receiverId: receiverId)
            
            self.chatText = ""
            self.scrollUpdate.send(1)
//            self.count += 1
        }
        
        let recipientMessageDocument = KBFBManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(receiverId)
            .collection(senderId)
            .document()
        
        try? recipientMessageDocument.setData(from: message) { [weak self] error in
            guard let self else { return }
            if let error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage(senderId: String, receiverId: String) {
        guard let chatUser = chatUser else { return }
        
        let document = KBFBManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(senderId)
            .collection(FirebaseConstants.messages)
            .document(receiverId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: senderId,
            FirebaseConstants.toId: receiverId,
            FirebaseConstants.profilePic: chatUser.profilePic,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        // you'll need to save another very similar dictionary for the recipient of this message...how?
        
        document.setData(data) { error in
            if let error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = KBFBManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: senderId,
            FirebaseConstants.toId: receiverId,
            FirebaseConstants.profilePic: currentUser.profilePic,
            FirebaseConstants.email: currentUser.email
        ] as [String : Any]
        
        KBFBManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(receiverId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
}
