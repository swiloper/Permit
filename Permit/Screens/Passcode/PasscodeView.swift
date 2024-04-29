//
//  PasscodeView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import NukeUI
import SwiftUI
import FirebaseFirestore

struct PasscodeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var users: UserManager
    @EnvironmentObject private var station: EnergyGroupManager
    @StateObject private var model = FaceRecognitionViewModel()
    @State private var code: String = .empty
    
    // MARK: - Verify
    
    private func verify(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1), let user = users.current, !station.current.created.isEmpty {
            Task {
                let result = await model.verify(id: user.id, portrait: data)
                code = result.0 ?? .empty
                
                if !code.isEmpty {
                    do {
                        let document = FirebaseManager.shared.firestore.collection("groups").document(station.current.id).collection("journal").document()
                        let entry = Entry(id: document.documentID, user: user, timestamp: Timestamp())
                        try document.setData(from: entry)
                    } catch let error {
                        app.error = error
                    }
                } else {
                    app.error = AnyError.userNotVerified
                }
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Permit")
                .toolbar {
                    ToolbarItem {
                        avatar
                    } //: ToolbarItem
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
                    Text("Allow camera access in settings to scan your face for recognition.")
                }
        } //: NavigationStack
    }
    
    // MARK: - Avatar
    
    @ViewBuilder
    private var avatar: some View {
        if let user = users.current {
            LazyImage(url: URL(string: user.image)) { state in
                ZStack {
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .transaction({ $0.animation = nil })
                    } else if state.isLoading || state.error == nil {
                        ProgressView()
                            .tint(.primary.opacity(0.6))
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.primary.opacity(0.6))
                    }
                } //: ZStack
                .animation(.default, value: [state.isLoading, state.image != nil, state.error == nil])
            } //: LazyImage
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.15))
            .clipShape(.circle)
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack {
            spacer
            permit
            spacer
            spacer
            action
        } //: VStack
        .padding(20)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea(.all, edges: .vertical))
        .fullScreenCover(item: $model.flow) { _ in
            ScanFaceView(model: CameraViewModel()) { portraits in
                if let first = portraits.first {
                    verify(image: first)
                }
            } //: ScanFaceView
        }
    }
    
    // MARK: - Permit
    
    @ViewBuilder
    private var permit: some View {
        let placeholder = Array(repeating: "–", count: 6).joined()
        let passcode = code.isEmpty ? placeholder : code
        let lenght = Int(passcode.count / 2)
        
        HStack(spacing: 30) {
            fragment(from: passcode.prefix(lenght).map({ String($0) }))
            fragment(from: passcode.suffix(lenght).map({ String($0) }))
        } //: HStack
        .font(.system(size: 40, weight: .semibold))
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
    
    // MARK: - Fragment
    
    private func fragment(from: [String]) -> some View {
        HStack(spacing: 12) {
            ForEach(from.indices, id: \.self) { index in
                Text(from[index])
            } //: ForEach
        } //: HStack
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            if !model.isLoading {
                model.permission { granted in
                    if granted {
                        model.flow = .verify
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
                    Text("Verify")
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
    PasscodeView()
}
