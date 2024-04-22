//
//  CameraImagePicker.swift
//  Permit
//
//  Created by Ihor Myronishyn on 03.04.2024.
//

import SwiftUI

@MainActor
struct CameraImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var completion: () -> Void = {}
    
    var source: UIImagePickerController.SourceType = .camera
    var device: UIImagePickerController.CameraDevice = .rear
    
    // MARK: - Make
    
    func makeCoordinator() -> CameraImagePicker.Coordinator {
        CameraImagePicker.Coordinator(image: $image, isPresented: $isPresented) {
            completion()
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.cameraDevice = device
        picker.delegate = context.coordinator
        return picker
    }
    
    // MARK: - Update
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here.
    }
}

// MARK: - Extension

extension CameraImagePicker {
    
    // MARK: - Coordinator
    
    @MainActor
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        // MARK: - Properties
        
        @Binding var image: UIImage?
        @Binding var isPresented: Bool
        let completion: () -> Void
        
        // MARK: - Init
        
        init(image: Binding<UIImage?>, isPresented: Binding<Bool>, completion: @escaping () -> Void = {}) {
            _image = image
            _isPresented = isPresented
            self.completion = completion
        }
        
        // MARK: - Picked
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let picked = info[.originalImage] as? UIImage {
                image = picked
            }
            
            completion()
            isPresented = false
        }
        
        // MARK: - Cancel
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            image = nil
            isPresented = false
        }
    }
}
