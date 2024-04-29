//
//  ScanFaceInstructionsView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import SwiftUI

struct ScanFaceInstructionsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var model: CameraViewModel
    
    private var prompt: String {
        if !model.isRecording, model.amount != 1 {
            return "Click the button below to start scanning."
        }
        
        switch model.faceDetectedState {
        case .faceDetectionErrored:
            return "An unexpected error occurred."
        case .noFaceDetected:
            return "Position your face within the frame."
        case .faceDetected:
            if model.isDetectedFaceValid {
                return model.amount == 1 ? "Take a photo for verification by clicking the button below." : "Change the emotion of your face to make the scan more accurate."
            } else if model.isAcceptableBounds == .detectedFaceTooSmall {
                return "Bring your face closer to the camera."
            } else if model.isAcceptableBounds == .detectedFaceTooLarge {
                return "Hold the camera further from your face."
            } else if model.isAcceptableBounds == .detectedFaceOffCentre {
                return "Center your face in the circle."
            } else if !model.isAcceptableRoll || !model.isAcceptablePitch || !model.isAcceptableYaw {
                return "Look straight at the camera."
            } else if !model.isAcceptableQuality {
                return "Image quality from the camera is too low."
            } else {
                return "Face scanning is currently not available."
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(prompt)
            .font(.system(size: 22, weight: .medium))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
    }
}

// MARK: - Preview

#Preview {
    ScanFaceInstructionsView(model: CameraViewModel())
}
