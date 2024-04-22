//
//  UserManager.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import Foundation

final class UserManager: ObservableObject {
    
    // MARK: - Properties
    
    @Published var current: User?
    @Published var all: [User] = []
    
    // MARK: - Init
    
    init() {
        fetch()
        load()
    }
    
    // MARK: - Fetch
    
    func fetch() {
        guard let id = FirebaseManager.shared.auth.currentUser?.uid else { return }
        FirebaseManager.shared.firestore.collection("users").document(id).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            current = try? snapshot?.data(as: User.self)
        }
    }
    
    // MARK: - Load
    
    func load() {
        FirebaseManager.shared.firestore.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let self, let snapshot else { return }
            
            var result: [User] = []
            
            snapshot.documents.forEach {
                if let user = try? $0.data(as: User.self) {
                    result.append(user)
                }
            }
            
            all = result
        }
    }
}
