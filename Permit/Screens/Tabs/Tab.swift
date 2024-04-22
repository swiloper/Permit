//
//  Tab.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import SwiftUI

enum Tab: String, Identifiable, CaseIterable {
    
    // MARK: - Cases
    
    case group, permit
    
    // MARK: - Properties
    
    var id: String {
        rawValue
    }
    
    var title: String {
        rawValue.capitalized
    }
    
    func label(isSelected: Bool) -> some View {
        switch self {
        case .group:
            Label(title, systemImage: isSelected ? "person.3.fill" : "person.3")
        case .permit:
            Label(title, systemImage: isSelected ? "person.text.rectangle.fill" : "person.text.rectangle")
        }
    }
}
