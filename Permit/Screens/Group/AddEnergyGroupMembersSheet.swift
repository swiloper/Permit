//
//  AddEnergyGroupMembersSheet.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

struct AddEnergyGroupMembersSheet: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var users: UserManager
    
    @State private var keyword: String = .empty
    @State private var selection = Set<String>()
    
    let except: [User]
    let completion: ([User]) -> Void
    
    private var results: [User] {
        let all = users.all.filter({ !except.map({ $0.id }).contains($0.id) })
        
        if keyword.isEmpty {
            return all
        }
        
        return all.filter({ $0.name.lowercased().contains(keyword.lowercased()) || $0.surname.lowercased().contains(keyword.lowercased()) || $0.email.lowercased().contains(keyword.lowercased()) })
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Members")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .searchable(text: $keyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                .toolbar {
                    toolbar
                }
        } //: NavigationStack
        .presentationCornerRadius(16)
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        if results.isEmpty {
            empty
        } else {
            list
        }
    }
    
    // MARK: - List
    
    private var list: some View {
        List(results, selection: $selection) { user in
            EnergyGroupMemberRowView(member: user)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.white)
        } //: List
        .environment(\.editMode, .constant(.active))
        .environment(\.defaultMinListHeaderHeight, .zero)
        .padding(.vertical, -18)
    }
    
    // MARK: - Empty
    
    private var empty: some View {
        ContentUnavailableView("Empty", systemImage: "person.fill.questionmark", description: Text("No users found."))
            .background {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea(.all, edges: .vertical)
            }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            } //: Button
        } //: ToolbarItem
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                var members: [User] = []
                
                selection.forEach { id in
                    if let user = users.all.first(where: { $0.id == id }) {
                        members.append(user)
                    }
                }
                
                completion(members)
                dismiss()
            } label: {
                Text("Add")
            } //: Button
        } //: ToolbarItem
    }
}

// MARK: - Preview

#Preview {
    AddEnergyGroupMembersSheet(except: []) {
        print($0)
    } //: AddEnergyGroupMembersSheet
}
