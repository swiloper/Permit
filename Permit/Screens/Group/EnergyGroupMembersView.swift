//
//  EnergyGroupMembersView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI
import FirebaseFirestore

@MainActor
struct EnergyGroupMembersView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var users: UserManager
    @EnvironmentObject private var station: EnergyGroupManager
    
    @State private var isAddMembersSheetVisible: Bool = false
    @Binding var group: EnergyGroup
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(group.members) { user in
                EnergyGroupMemberRowView(member: user)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .deleteDisabled((group.created == user.id && station.current.created == users.current?.id) || station.current.created != users.current?.id)
            } //: ForEach
            .onDelete { set in
                var deleted: String = .empty
                if let index = set.first {
                    deleted = group.members[index].id
                }
                
                group.members.remove(atOffsets: set)
                station.update { error in
                    app.error = error
                    
                    if app.error == nil, !deleted.isEmpty {
                        Task {
                            do {
                                try await FirebaseManager.shared.firestore.collection("users").document(deleted).updateData(["group": FieldValue.delete()])
                            } catch {
                                app.error = error
                            }
                        }
                    }
                }
            }
        } //: List
        .navigationTitle("Members")
        .toolbar {
            if station.current.created == users.current?.id {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddMembersSheetVisible.toggle()
                    } label: {
                        Text("Add")
                    } //: Button
                } //: ToolbarItem
            }
        }
        .sheet(isPresented: $isAddMembersSheetVisible) {
            AddEnergyGroupMembersSheet(except: group.members) { added in
                group.members.append(contentsOf: added)
                station.update { error in
                    app.error = error
                    
                    if app.error == nil {
                        added.forEach { member in
                            Task {
                                do {
                                    try await FirebaseManager.shared.firestore.collection("users").document(member.id).updateData(["group": group.id])
                                } catch {
                                    app.error = error
                                }
                            }
                        }
                    }
                }
            } //: AddEnergyGroupMembersSheet
        }
    }
}

// MARK: - Preview

#Preview {
    EnergyGroupMembersView(group: .constant(.empty))
}
