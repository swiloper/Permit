//
//  FaceRecognitionViewModel.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI
import AVFoundation

@MainActor
final class FaceRecognitionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isLoading: Bool = false
    @Published var flow: Flow?
    @Published var isCameraAccessAlertVisible: Bool = false
    
    enum Flow: String, Identifiable {
        case scan, verify
        
        var id: String {
            self.rawValue
        }
    }
    
    struct ScanResponse: Decodable {
        let isRegisterCompleted: Bool
    }
    
    struct VerifyResponse: Decodable {
        let passcode: String
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
    
    func scan(id: String, portraits: [Data]) async -> (Bool, Error?) {
        isLoading = true
        
        let parameters: [String : Any] = [
            "id": id,
            "images": portraits.map({ $0.base64EncodedString() })
        ]
        
        do {
            let response = try await NetworkService.shared.request(link: EndpointPath.scan, parameters: parameters, method: .post, decode: ScanResponse.self)
            isLoading = false
            return (response.isRegisterCompleted, nil)
        } catch {
            isLoading = false
            return (false, error)
        }
    }
    
    // MARK: - Verify
    
    func verify(id: String, portrait: Data) async -> (String?, Error?) {
        isLoading = true
        
        let parameters: [String : Any] = [
            "id": id,
            "image": portrait.base64EncodedString()
        ]
        
        do {
            let response = try await NetworkService.shared.request(link: EndpointPath.authenticate, parameters: parameters, method: .post, decode: VerifyResponse.self)
            isLoading = false
            return (response.passcode, nil)
        } catch {
            isLoading = false
            return (nil, error)
        }
    }
}
