//
//  CreateEnergyGroupPromptView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

struct CreateEnergyGroupPromptView: View {
    
    // MARK: - Properties
    
    @State private var isCreationFormVisible: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            spacer
            content
            spacer
            action
        } //: VStack
        .padding(20)
        .sheet(isPresented: $isCreationFormVisible) {
            CreateEnergyGroupForm()
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack {
            image
            container
        } //: VStack
    }
    
    // MARK: - Image
    
    private var image: some View {
        Image("station")
            .resizable()
            .scaledToFit()
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
        Text("Group")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.primary)
    }
    
    // MARK: - Details
    
    private var details: some View {
        Text("Create a new group tied to an energy facility, or ask your manager to add you to an existing one.")
            .multilineTextAlignment(.center)
            .font(.system(size: 17))
            .foregroundStyle(.gray)
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            isCreationFormVisible.toggle()
        } label: {
            Text("Add")
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
    CreateEnergyGroupPromptView()
}
