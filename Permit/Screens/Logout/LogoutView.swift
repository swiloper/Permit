//
//  LogoutView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI

struct LogoutView: View {
    
    // MARK: - Properties
    
    @AppStorage("isAuthorized") private var isAuthorized = false
    @EnvironmentObject private var app: AppState
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            spacer
            action
        } //: VStack
        .padding(20)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea(.all, edges: .vertical))
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            do {
                try FirebaseManager.shared.auth.signOut()
                isAuthorized = false
            } catch let error {
                app.error = error
            }
        } label: {
            Text("Logout")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
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
    LogoutView()
}
