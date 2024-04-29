//
//  CameraView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    private(set) var model: CameraViewModel
    
    // MARK: - Make
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let detector = FaceDetector()
        detector.model = model
        
        let controller = CameraViewController()
        controller.faceDetector = detector
        
        return controller
    }
    
    // MARK: - Update
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Nothing to update.
    }
}
