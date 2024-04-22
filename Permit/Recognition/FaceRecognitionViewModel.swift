//
//  FaceRecognitionViewModel.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI
import AVFoundation

extension FaceRecognitionViewModel.Popup {
    static let empty = FaceRecognitionViewModel.Popup(title: "", message: "")
}

@MainActor
final class FaceRecognitionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var selection: UIImage?
    @Published var isLoading: Bool = false
    @Published var flow: Flow?
    @Published var popup: Popup = .empty
    @Published var isAlertVisible: Bool = false
    
    struct Popup {
        let title: String
        let message: String
    }
    
    enum Flow: String, Identifiable {
        case scan, verify
        
        var id: String {
            self.rawValue
        }
    }
    
    struct RegisterResponse: Decodable {
        let isRegisterCompleted: Bool
    }
    
    struct VerifyResponse: Decodable {
        let isIdentified: Bool
    }
    
    // MARK: - Permission
    
    func permission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Camera access already granted.
            completion(true)
        case .denied, .restricted:
            // Camera access denied or restricted.
            completion(false)
        case .notDetermined:
            // Request camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Register
    
    func scan(id: String, portrait: Data) async -> Bool {
        isLoading = true
        
        let parameters: [String : Any] = [
            "id": id,
            "image": portrait.base64EncodedString()
        ]
        
        do {
            let response = try await NetworkService.shared.request(link: EndpointPath.scan, parameters: parameters, method: .post, decode: RegisterResponse.self)
            isLoading = false
            return response.isRegisterCompleted
        } catch {
            print(error.localizedDescription)
            isLoading = false
            return false
        }
    }
}

