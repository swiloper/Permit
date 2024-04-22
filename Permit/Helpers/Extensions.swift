//
//  Extensions.swift
//  Permit
//
//  Created by Ihor Myronishyn on 03.04.2024.
//

import SwiftUI

// MARK: - String

extension String {
    static let empty = ""
    static let space = " "
}

// MARK: - UIApplication

extension UIApplication {
    func submit() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
