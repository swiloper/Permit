//
//  ScanFaceView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import SwiftUI

struct ScanFaceView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private(set) var model: CameraViewModel
    private(set) var competion: ([UIImage]) -> Void
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let padding: CGFloat = 60
    
    // MARK: - Init
    
    init(model: CameraViewModel, competion: @escaping ([UIImage]) -> Void) {
        self.model = model
        self.competion = competion
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            content
            overlay
        } //: ZStack
        .preferredColorScheme(.dark)
        .modifier(ReadSizeModifier())
        .onPreferenceChange(ViewSizeKey.self) { size in
            if let size {
                model.perform(action: .windowSizeDetected(CGRect(origin: .zero, size: size), padding))
            }
        }
        .onChange(of: model.portraits.count) {
            if $1 == model.amount {
                competion(model.portraits)
                dismiss()
            }
        }
        .onReceive(timer) { _ in
            if !model.portraits.isEmpty, model.isDetectedFaceValid {
                model.perform(action: .takePhoto)
            }
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        ZStack {
            if model.faceLayoutGuideFrame != .zero {
                camera
                guide
            }
        } //: ZStack
        .ignoresSafeArea(.container, edges: .vertical)
    }
    
    // MARK: - Camera
    
    private var camera: some View {
        CameraView(model: model)
            .mask {
                Circle()
                    .frame(width: model.faceLayoutGuideFrame.width, height: model.faceLayoutGuideFrame.height)
            }
    }
    
    // MARK: - Guide
    
    private var guide: some View {
        Circle()
            .strokeBorder(model.isDetectedFaceValid ? .green : .red, lineWidth: 6)
            .frame(width: model.faceLayoutGuideFrame.width, height: model.faceLayoutGuideFrame.height)
    }
    
    // MARK: - Overlay
    
    private var overlay: some View {
        GeometryReader { proxy in
            VStack {
                ScanFaceInstructionsView(model: model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                    .frame(height: proxy.size.width * 4 / 3)
                
                CameraControlsView(model: model) {
                    dismiss()
                } //: CameraControlsView
            } //: VStack
        } //: GeometryReader
    }
}

// MARK: - Preview

#Preview {
    ScanFaceView(model: CameraViewModel()) { _ in
        print("Completion")
    } //: ScanFaceView
}
