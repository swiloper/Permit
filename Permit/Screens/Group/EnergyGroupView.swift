//
//  EnergyGroupView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

struct EnergyGroupView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var users: UserManager
    @StateObject private var station = EnergyGroupManager()
    
    let id: String
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            list
                .navigationTitle("Group")
        } //: NavigationStack
        .environmentObject(station)
        .task {
            station.fetch(with: id)
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        if station.current.created.isEmpty {
            loading
        } else {
            list
        }
    }
    
    // MARK: - Loading
    
    private var loading: some View {
        ProgressView()
            .tint(.primary)
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - List
    
    private var list: some View {
        List {
            Section {
                
            } header: {
                header
            } //: Section
        } //: List
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 14) {
            container
            members
        } //: VStack
        .textCase(.none)
        .padding(16)
        .background(.white)
        .clipShape(.rect(cornerRadius: 10))
        .listRowInsets(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
    }
    
    // MARK: - Container
    
    private var container: some View {
        HStack(alignment: .top, spacing: 14) {
            image
            descritpion
        } //: HStack
    }
    
    // MARK: - Members
    
    private var members: some View {
        HStack(alignment: .bottom) {
            let count = station.current.members.count
            Text("\(count) \(count == 1 ? "member" : "members")")
            spacer
            manage
        } //: HStack
    }
    
    // MARK: - Manage
    
    private var manage: some View {
        NavigationLink {
            EnergyGroupMembersView(group: $station
                .current)
        } label: {
            Text(station.current.created == users.current?.id ? "Manage" : "View")
        } //: NavigationLink
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - Image
    
    private var image: some View {
        Image("placeholder")
            .resizable()
            .scaledToFit()
            .frame(height: 100)
    }
    
    // MARK: - Descritpion
    
    private var descritpion: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(station.current.name)
                .lineLimit(2)
                .foregroundStyle(.black)
                .font(.system(size: 18, weight: .semibold))
            
            Text(station.current.details)
                .lineLimit(3)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        } //: VStack
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Spacer
    
    private var spacer: some View {
        Spacer(minLength: .zero)
    }
}

// MARK: - Preview

#Preview {
    EnergyGroupView(id: .empty)
}
