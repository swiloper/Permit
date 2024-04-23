//
//  EnergyGroupView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

enum EnergyGroupRoute {
    case members
}

struct EnergyGroupView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var users: UserManager
    @EnvironmentObject private var station: EnergyGroupManager
    
    
    @State private var path: [EnergyGroupRoute] = []
    
    let id: String
    
    var sections: [GroupedSection<Date, Entry>] {
        let sections = GroupedSection.group(rows: station.journal) {
            guard let day = $0.date.day else { return Date.now }
            return day
        } sorted: {
            $0.date > $1.date
        }
        
        return sections.sorted(by: { $0.headline > $1.headline })
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $path) {
            list
                .navigationTitle("Group")
                .navigationDestination(for: EnergyGroupRoute.self) { route in
                    switch route {
                    case .members:
                        EnergyGroupMembersView(group: $station.current)
                    }
                }
        } //: NavigationStack
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
            header
            
            ForEach(sections, id: \.headline) { section in
                Section(header: Text(section.headline.format(date: .long, time: .none))) {
                    ForEach(section.rows) { entry in
                        EnergyGroupMemberRowView(member: entry.user, description: entry.timestamp.dateValue().format(date: .none, time: .short))
                    } //: ForEach
                } //: Section
            } //: ForEach
        } //: List
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 14) {
            container
            members
        } //: VStack
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
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
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            
            spacer
            manage
        } //: HStack
    }
    
    // MARK: - Manage
    
    private var manage: some View {
        Button {
            path.append(.members)
        } label: {
            Text(station.current.created == users.current?.id ? "Manage" : "View")
                .font(.system(size: 15, weight: .semibold))
                .frame(height: 28)
                .padding(.horizontal, 12)
                .foregroundStyle(.white)
                .background(Color.accentColor)
                .clipShape(.rect(cornerRadius: 6))
                .contentShape(.rect)
        } //: Button
        .buttonStyle(.plain)
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
                .foregroundStyle(.primary)
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
