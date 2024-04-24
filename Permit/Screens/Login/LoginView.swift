//
//  LoginView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI
import PhotosUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @AppStorage("isAuthorized") private var isAuthorized = false
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var users: UserManager
    @StateObject private var model = LoginViewModel()
    
    // MARK: - Authorize
    
    private func authorize() {
        if model.flow == .register {
            model.register {
                completion($0)
            }
        } else {
            model.login {
                completion($0)
            }
        }
    }
    
    // MARK: - Completion
    
    private func completion(_ error: Error?) {
        app.error = error
        model.isLoading = false
        
        if app.error == nil {
            isAuthorized = true
            users.fetch()
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            spacer
            avatar
            fields
            prompt
            spacer
            action
        } //: VStack
        .padding(20)
        .animation(.default, value: model.flow)
        .background {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea(.all, edges: .vertical)
                .onTapGesture {
                    UIApplication.shared.submit()
                }
        }
    }
    
    // MARK: - Avatar
    
    private var avatar: some View {
        PhotosPicker(selection: $model.photo, matching: .any(of: [.images, .not(.livePhotos)])) {
            ZStack {
                if let data = model.data, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                }
            } //: ZStack
            .animation(.default, value: model.data)
            .frame(width: 100, height: 100)
            .clipShape(.circle)
        } //: PhotosPicker
        .padding(16)
        .onChange(of: model.photo) { old, new in
            Task {
                if let loaded = try? await new?.loadTransferable(type: Data.self) {
                    model.data = loaded
                }
            }
        }
        .opacity(model.flow == .register ? 1 : .zero)
        .disabled(model.flow == .login)
    }
    
    // MARK: - Fields
    
    private var fields: some View {
        VStack(spacing: 12) {
            container
            email
            password
        } //: VStack
    }
    
    // MARK: - Container
    
    private var container: some View {
        HStack(spacing: 12) {
            name
            surname
        } //: HStack
        .opacity(model.flow == .register ? 1 : .zero)
        .disabled(model.flow == .login)
    }
    
    // MARK: - Name
    
    private var name: some View {
        TextField(String.empty, text: $model.name, prompt: Text("Name"))
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Surname
    
    private var surname: some View {
        TextField(String.empty, text: $model.surname, prompt: Text("Surname"))
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Email
    
    private var email: some View {
        TextField(String.empty, text: $model.email, prompt: Text("Email"))
            .autocapitalization(.none)
            .textContentType(.oneTimeCode)
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Password
    
    private var password: some View {
        SecureField(String.empty, text: $model.password, prompt: Text("Password"))
            .autocapitalization(.none)
            .textContentType(.oneTimeCode)
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
    }
    
    // MARK: - Prompt
    
    private var prompt: some View {
        Button {
            model.flow = model.flow == .login ? .register : .login
        } label: {
            Group {
                Text(model.flow == .register ? "Already have an account?" : "New user?")
                    .foregroundColor(Color(uiColor: .darkGray))
                +
                Text(String.space + "Sign" + String.space + (model.flow == .register ? "In" : "Up"))
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            } //: Group
            .frame(maxWidth: .infinity)
            .padding(16)
            .contentShape(.rect)
        } //: Button
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            authorize()
        } label: {
            ZStack {
                if model.isLoading {
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                } else {
                    Text(model.flow == .register ? "Sign Up" : "Sign In")
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
    LoginView()
}
