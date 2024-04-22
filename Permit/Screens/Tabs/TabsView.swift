//
//  TabsView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

struct TabsView: View {
    
    // MARK: - Properties
    
    @State private var selection: Tab = .group
    
    let id: String
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(Tab.allCases) { tab in
                Group {
                    switch tab {
                    case .group:
                        EnergyGroupView(id: id)
                    case .permit:
                        EmptyView()
                    }
                }
                .tag(tab)
                .tabItem {
                    tab.label(isSelected: selection == tab)
                }
            } //: ForEach
            .toolbarBackground(.visible, for: .tabBar)
        } //: TabView
    }
}

// MARK: - Preview

#Preview {
    TabsView(id: .empty)
}
