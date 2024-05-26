//
//  KBFBManager.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 26/05/2024.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class KBFBManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: KBChatUser?
    
    static let shared = KBFBManager()
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
    

}
