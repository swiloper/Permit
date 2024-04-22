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
    
    // MARK: - Init
    
    init() {
        fetch()
    }
    
    // MARK: - Fetch
    
    func fetch() {
        guard let id = FirebaseManager.shared.auth.currentUser?.uid else { return }
        FirebaseManager.shared.firestore.collection("users").document(id).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            current = try? snapshot?.data(as: User.self)
        }
    }
}
