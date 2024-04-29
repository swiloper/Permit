//
//  ShutterButton.swift
//  Permit
//
//  Created by Ihor Myronishyn on 29.04.2024.
//

import SwiftUI

struct ShutterButton: View {
    
    // MARK: - Properties
    
    @ObservedObject var model: CameraViewModel
    
    // MARK: - Methods
    
    private func action() {
        model.perform(action: .takePhoto)
        
        if model.amount != 1, !model.isRecording {
            model.isRecording.toggle()
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                container
                progress
            } //: ZStack
        } //: Button
        .disabled(!model.isDetectedFaceValid)
    }
    
    // MARK: - Container
    
    private var container: some View {
        ZStack {
            circle(foregroundColor: .red, isVisible: model.isRecording)
                .frame(width: 36, height: 36)
            
            circle(foregroundColor: .white, isVisible: !model.isRecording)
                .frame(width: 50, height: 50)
        } //: ZStack
        .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: model.isRecording)
        .frame(width: 72, height: 72)
        .overlay {
            Circle()
                .strokeBorder(.white, lineWidth: 4)
        }
        .opacity(!model.isDetectedFaceValid && !model.isRecording ? 0.5 : 1)
    }
    
    // MARK: - Circle
    
    private func circle(foregroundColor: Color, isVisible: Bool) -> some View {
        Circle()
            .foregroundStyle(foregroundColor)
            .scaleEffect(isVisible ? 1 : 0.01)
            .opacity(isVisible ? 1 : .zero)
    }
    
    // MARK: - Progress
    
    private var progress: some View {
        CircularProgressView(progress: Double(model.portraits.count) / Double(model.amount), lineWidth: 5, foregroundColor: .blue)
            .frame(width: 90, height: 90)
    }
}

// MARK: - Preview

#Preview {
    ShutterButton(model: CameraViewModel())
}
