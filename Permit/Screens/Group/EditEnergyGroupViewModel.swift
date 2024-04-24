//
//  EditEnergyGroupViewModel.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

final class EditEnergyGroupViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var group: EnergyGroup = .empty
    @Published var isLoading: Bool = false
    
    // MARK: - Init
    
    init(group: EnergyGroup = .empty) {
        self.group = group
    }
    
    // MARK: - Create
    
    func create(with: User, completion: @escaping (EnergyGroup?, Error?) -> Void) {
        isLoading = true
        
        do {
            let document = FirebaseManager.shared.firestore.collection("groups").document()
            let group = EnergyGroup(id: document.documentID, name: group.name, details: group.details, location: group.location, created: with.id, members: [with])
            try document.setData(from: group)
            isLoading = false
            completion(group, nil)
        } catch let error {
            isLoading = false
            completion(nil, error)
        }
    }
    
    // MARK: - Edit
    
    func edit(completion: @escaping (Error?) -> Void) {
        isLoading = true
        
        do {
            try FirebaseManager.shared.firestore.collection("groups").document(group.id).setData(from: group)
            isLoading = false
            completion(nil)
        } catch let error {
            isLoading = false
            completion(error)
        }
    }
}
