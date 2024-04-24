//
//  RoundedTextFieldModifier.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import SwiftUI

struct RoundedTextFieldModifier: ViewModifier {
    
    // MARK: - Properties
    
    var keyboard: UIKeyboardType = .default
    
    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .keyboardType(keyboard)
            .autocorrectionDisabled()
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 10))
    }
}
