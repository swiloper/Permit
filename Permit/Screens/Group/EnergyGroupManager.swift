//
//  EnergyGroupManager.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

final class EnergyGroupManager: ObservableObject {
    
    // MARK: - Properties
    
    @Published var current: EnergyGroup = .empty
    
    // MARK: - Fetch
    
    func fetch(with id: String) {
        FirebaseManager.shared.firestore.collection("groups").document(id).addSnapshotListener { [weak self] snapshot, error in
            guard let self, let snapshot, let group = try? snapshot.data(as: EnergyGroup.self) else { return }
            current = group
        }
    }
    
    // MARK: - Update
    
    func update(completion: @escaping (Error?) -> Void) {
        do {
            try FirebaseManager.shared.firestore.collection("groups").document(current.id).setData(from: current)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
}
