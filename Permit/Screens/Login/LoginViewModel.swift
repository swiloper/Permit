//
//  LoginViewModel.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import PhotosUI
import SwiftUI
import FirebaseFirestoreSwift

@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var photo: PhotosPickerItem?
    @Published var data: Data?
    @Published var name: String = .empty
    @Published var surname: String = .empty
    @Published var email: String = .empty
    @Published var password: String = .empty
    
    @Published var isLoading: Bool = false
    @Published var flow: Flow = .register
    
    enum Flow {
        case register, login
    }
    
    // MARK: - Login
    
    func login(completion: @escaping (Error?) -> Void) {
        isLoading = true
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            isLoading = false
            completion(error)
        }
    }
    
    // MARK: - Register

    func register(completion: @escaping (Error?) -> Void) {
        isLoading = true
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            isLoading = false
            
            if let error {
                completion(error)
                return
            }
            
            storage(data: data, name: name, surname: surname, email: email)
            completion(nil)
        }
    }
    
    // MARK: - Storage
    
    private func storage(data: Data?, name: String, surname: String, email: String) {
        guard let id = FirebaseManager.shared.auth.currentUser?.uid, let data else { return }
        let reference = FirebaseManager.shared.storage.reference(withPath: id)
        
        reference.putData(data, metadata: nil) { metadata, error in
            if let error {
                return
            }
            
            reference.downloadURL { [weak self] link, error in
                guard let self else { return }
                if let error {
                    return
                }
                
                if let link {
                    information(link: link, name: name, surname: surname, email: email)
                }
            }
        }
    }
    
    // MARK: - Information
    
    private func information(link: URL, name: String, surname: String, email: String) {
        guard let id = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let user = User(id: id, image: link.absoluteString, name: name, surname: surname, email: email, isFaceScanned: false)
        
        do {
            try FirebaseManager.shared.firestore.collection("users").document(id).setData(from: user)
        } catch let error {
            return
        }
    }
}
