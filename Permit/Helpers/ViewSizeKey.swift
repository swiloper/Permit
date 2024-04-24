//
//  ViewSizeKey.swift
//  Permit
//
//  Created by Ihor Myronishyn on 24.04.2024.
//

import SwiftUI

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize?
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        guard let next = nextValue() else { return }
        value = next
    }
}
