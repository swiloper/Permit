//
//  ScanFaceView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI

struct ScanFaceView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var app: AppState
    @StateObject private var model = FaceRecognitionViewModel()
    
    // MARK: - Scan
    
    private func scan() {
        if let selection = model.selection, let data = selection.jpegData(compressionQuality: 1), let user = FirebaseManager.shared.auth.currentUser {
            Task {
                let result = await model.scan(id: user.uid, portrait: data)
                
                if result.0 {
                    guard let id = FirebaseManager.shared.auth.currentUser?.uid else { return }
                    
                    do {
                        try await FirebaseManager.shared.firestore.collection("users").document(id).updateData(["isFaceScanned": true])
                    } catch {
                        app.error = error
                    }
                } else {
                    app.error = result.1
                }
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            spacer
            content
            spacer
            action
        } //: VStack
        .padding(20)
        .background(Color.white.ignoresSafeArea(.all, edges: .vertical))
        .navigationBarBackButtonHidden()
        .sheet(item: $model.flow) { _ in
            picker
        }
        .alert("Camera Access Denied", isPresented: $model.isCameraAccessAlertVisible) {
            Button {
                guard let link = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(link) else { return }
                UIApplication.shared.open(link)
            } label: {
                Text("Settings")
            } //: Button
            
            Button(role: .cancel) {
                model.isCameraAccessAlertVisible = false
            } label: {
                Text("Cancel")
            } //: Button
        } message: {
            Text("Allow camera access in settings to scan your face for further recognition.")
        }
    }
    
    // MARK: - Picker
    
    @ViewBuilder
    private var picker: some View {
        let isCameraImagePickerPresented: Binding<Bool> = Binding {
            model.flow != nil
        } set: {
            model.flow = $0 ? model.flow : nil
        }
        
        CameraImagePicker(image: $model.selection, isPresented: isCameraImagePickerPresented) {
            scan()
        } //: CameraImagePicker
        .background(.black)
        .presentationCornerRadius(16)
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(spacing: 16) {
            image
            container
        } //: VStack
    }
    
    // MARK: - Image
    
    private var image: some View {
        Image(systemName: "faceid")
            .font(.system(size: 100))
            .padding(20)
    }
    
    // MARK: - Container
    
    private var container: some View {
        VStack(spacing: 10) {
            title
            details
        } //: VStack
    }
    
    // MARK: - Title
    
    private var title: some View {
        Text("Scan")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.primary)
    }
    
    // MARK: - Details
    
    private var details: some View {
        Text("Scan your face for further recognition and getting access to the energy object.")
            .multilineTextAlignment(.center)
            .font(.system(size: 17))
            .foregroundStyle(.gray)
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            if !model.isLoading {
                model.permission { granted in
                    if granted {
                        model.flow = .scan
                    } else {
                        model.isCameraAccessAlertVisible.toggle()
                    }
                }
            }
        } label: {
            ZStack {
                if model.isLoading {
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                } else {
                    Text("Scan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            } //: ZStack
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .contentShape(.rect)
        } //: Button
        .background(Color.accentColor)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    // MARK: - Spacer
    
    private var spacer: some View {
        Spacer(minLength: .zero)
    }
}

// MARK: - Preview

#Preview {
    ScanFaceView()
}
