//
//  AppState.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI

final class AppState: ObservableObject {
    
    // MARK: - Properties
    
    @Published var error: Error?
    
    var isErrorAlertVisible: Binding<Bool> {
        Binding {
            self.error != nil
        } set: {
            if !$0 {
                self.error = nil
            }
        }
    }
}
