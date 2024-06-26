//
//  MainView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Properties
    
    @AppStorage("isAuthorized") private var isAuthorized = false
    @EnvironmentObject private var users: UserManager
    
    @State private var isLoginVisible: Bool = true
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if !isAuthorized {
                LoginView()
            } else if let user = users.current {
                if !user.isFaceScanned {
                    ScanFacePromptView()
                } else if let group = user.group {
                    TabsView(id: group)
                } else {
                    CreateEnergyGroupPromptView()
                }
            }
        } //: ZStack
        .animation(.default, value: isAuthorized)
    }
}

// MARK: - Preview

#Preview {
    MainView()
}
