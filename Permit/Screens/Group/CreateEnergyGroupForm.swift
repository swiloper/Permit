//
//  CreateEnergyGroupForm.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

struct CreateEnergyGroupForm: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var users: UserManager
    @StateObject private var model = CreateEnergyGroupViewModel()
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            spacer
            container
            spacer
            action
        } //: VStack
        .padding(20)
        .background {
            Color(uiColor: .systemGray6)
                .ignoresSafeArea(.all, edges: .vertical)
                .onTapGesture {
                    UIApplication.shared.submit()
                }
        }
    }
    
    // MARK: - Container
    
    private var container: some View {
        VStack(spacing: 12) {
            name
            details
            location
        } //: VStack
    }
    
    // MARK: - Name
    
    private var name: some View {
        TextField(String.empty, text: $model.name, prompt: Text("Name"))
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Details
    
    private var details: some View {
        TextField(String.empty, text: $model.details, prompt: Text("Details"), axis: .vertical)
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Location
    
    private var location: some View {
        TextField(String.empty, text: $model.location, prompt: Text("Location"))
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            if let user = users.current {
                model.create(with: user) { group, error in
                    app.error = error
                    
                    if let group, app.error == nil {
                        Task {
                            do {
                                try await FirebaseManager.shared.firestore.collection("users").document(user.id).updateData(["group": group.id])
                                dismiss()
                            } catch {
                                app.error = error
                            }
                        }
                    }
                }
            } else {
                app.error = AnyError.userNotFound
            }
        } label: {
            ZStack {
                if model.isLoading {
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                } else {
                    Text("Create")
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
    CreateEnergyGroupForm()
}
