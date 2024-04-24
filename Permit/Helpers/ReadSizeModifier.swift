//
//  ReadSizeModifier.swift
//  Permit
//
//  Created by Ihor Myronishyn on 24.04.2024.
//

import SwiftUI

struct ReadSizeModifier: ViewModifier {
    
    // MARK: - Properties
    
    private var size: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ViewSizeKey.self, value: proxy.size)
        } //: GeometryReader
    }
    
    // MARK: - Body

    func body(content: Content) -> some View {
        content.background(size)
    }
}
