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

// MARK: - DateFormatter

extension Date {
    var day: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        guard let result = calendar.date(from: components) else { return nil }
        return result
    }
    
    func format(date: DateFormatter.Style, time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }
}
