//
//  EnergyGroupMemberRowView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import NukeUI
import SwiftUI

@MainActor
struct EnergyGroupMemberRowView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var station: EnergyGroupManager
    
    let member: User
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 10) {
            avatar
            container
            spacer
            manager
        } //: HStack
    }
    
    // MARK: - Avatar
    
    private var avatar: some View {
        LazyImage(url: URL(string: member.image)) { state in
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
                        .foregroundStyle(.primary.opacity(0.6))
                }
            } //: ZStack
            .animation(.default, value: [state.isLoading, state.image != nil, state.error == nil])
        } //: LazyImage
        .frame(width: 40, height: 40)
        .background(Color.gray.opacity(0.15))
        .clipShape(.circle)
    }
    
    // MARK: - Container
    
    private var container: some View {
        VStack(alignment: .leading, spacing: .zero) {
            name
            email
        } //: VStack
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Name
    
    private var name: some View {
        Text("\(member.name) \(member.surname)")
            .foregroundStyle(.primary)
            .font(.system(size: 17))
    }
    
    // MARK: - Email
    
    private var email: some View {
        Text(member.email)
            .foregroundStyle(.gray)
            .font(.system(size: 15))
    }
    
    // MARK: - Manager
    
    @ViewBuilder
    private var manager: some View {
        if station.current.created == member.id {
            Text("Manager")
                .foregroundStyle(.gray)
                .font(.system(size: 13))
        }
    }
    
    // MARK: - Spacer
    
    private var spacer: some View {
        Spacer(minLength: .zero)
    }
}

// MARK: - Preview

#Preview {
    EnergyGroupMemberRowView(member: .empty)
}
