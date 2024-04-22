//
//  CreateEnergyGroupViewModel.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

final class CreateEnergyGroupViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var name: String = .empty
    @Published var details: String = .empty
    @Published var location: String = .empty
    @Published var isLoading: Bool = false
    
    // MARK: - Create
    
    func create(with: User, completion: @escaping (EnergyGroup?, Error?) -> Void) {
        do {
            let document = FirebaseManager.shared.firestore.collection("groups").document()
            let group = EnergyGroup(id: document.documentID, name: name, details: details, location: location, created: with.id, members: [with])
            try document.setData(from: group)
            completion(group, nil)
        } catch let error {
            completion(nil, error)
        }
    }
}
