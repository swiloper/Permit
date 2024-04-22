//
//  FirebaseManager.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import Firebase
import Foundation
import FirebaseStorage

final class FirebaseManager: NSObject {
    
    // MARK: - Properties
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    // MARK: - Init
    
    override init() {
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        super.init()
    }
}
