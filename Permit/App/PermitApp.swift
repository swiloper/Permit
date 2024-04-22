//
//  PermitApp.swift
//  Permit
//
//  Created by Ihor Myronishyn on 03.04.2024.
//

import SwiftUI

@main
struct PermitApp: App {
    
    // MARK: - Properties
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var users = UserManager()
    @StateObject private var app = AppState()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(app)
                .environmentObject(users)
                .environment(\.colorScheme, .light)
                .alert("Error", isPresented: app.isErrorAlertVisible) {
                    Button("OK") {
                        app.isErrorAlertVisible.wrappedValue = false
                    } //: Button
                } message: {
                    if let error = app.error {
                        Text(error.localizedDescription)
                    }
                }
        } //: WindowGroup
    }
}
