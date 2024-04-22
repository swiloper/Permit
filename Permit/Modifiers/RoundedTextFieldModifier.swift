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
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(.white)
            .clipShape(.rect(cornerRadius: 10))
    }
}
