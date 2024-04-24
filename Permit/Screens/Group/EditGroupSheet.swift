//
//  EditGroupSheet.swift
//  Permit
//
//  Created by Ihor Myronishyn on 24.04.2024.
//

import SwiftUI

struct EditGroupSheet: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var users: UserManager
    
    @StateObject private var model = EditEnergyGroupViewModel()

    @State private var height: CGFloat = .zero
    @State private var isLoading: Bool = false
    
    private let initial: EnergyGroup
    private let flow: Flow
    
    enum Flow {
        case create, edit
    }
    
    // MARK: - Init
    
    init(group: EnergyGroup = .empty, flow: Flow) {
        initial = group
        _model = StateObject(wrappedValue: EditEnergyGroupViewModel(group: group))
        self.flow = flow
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            fit
            spacer
        } //: VStack
        .presentationDetents([.height(height)])
        .presentationCornerRadius(16)
    }
    
    // MARK: - Fit
    
    private var fit: some View {
        ViewThatFits(in: .vertical) {
            content
            
            ScrollView(.vertical) {
                content
            } //: ScrollView
            .scrollIndicators(.hidden)
        } //: ViewThatFits
        .disabled(flow == .edit && initial.created != users.current?.id)
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(spacing: 40) {
            container
            action
        } //: VStack
        .padding(20)
        .modifier(ReadSizeModifier())
        .onPreferenceChange(ViewSizeKey.self) { size in
            if let size {
                height = size.height
            }
        }
        .background {
            Color(uiColor: .systemGroupedBackground)
                .scaleEffect(5)
                .ignoresSafeArea(.all, edges: .vertical)
                .onTapGesture {
                    UIApplication.shared.submit()
                }
        }
    }
    
    // MARK: - Container
    
    private var container: some View {
        VStack(spacing: 12) {
            Group {
                name
                details
                location
            } //: Group
            .autocapitalization(.none)
            .textContentType(.oneTimeCode)
            .modifier(RoundedTextFieldModifier(keyboard: .alphabet))
            .fixedSize(horizontal: false, vertical: true)
        } //: VStack
    }
    
    // MARK: - Name
    
    private var name: some View {
        TextField(String.empty, text: $model.group.name, prompt: Text("Name"), axis: .vertical)
    }
    
    // MARK: - Details
    
    private var details: some View {
        TextField(String.empty, text: $model.group.details, prompt: Text("Details"), axis: .vertical)
    }
    
    // MARK: - Location
    
    private var location: some View {
        TextField(String.empty, text: $model.group.location, prompt: Text("Location"), axis: .vertical)
    }
    
    // MARK: - Action
    
    private var action: some View {
        Button {
            if flow == .create {
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
            } else {
                model.edit { error in
                    if let error {
                        app.error = error
                    } else {
                        dismiss()
                    }
                }
            }
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                } else {
                    Text(flow == .create ? "Create" : "Update")
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
        .disabled(flow == .edit && model.group == initial)
    }
    
    // MARK: - Spacer
    
    private var spacer: some View {
        Spacer(minLength: .zero)
    }
}

// MARK: - Preview

#Preview {
    EditGroupSheet(group: .empty, flow: .create)
}
