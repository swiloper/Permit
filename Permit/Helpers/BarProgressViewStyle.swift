//
//  BarProgressViewStyle.swift
//  Permit
//
//  Created by Ihor Myronishyn on 01.05.2024.
//

import SwiftUI

struct BarProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .frame(height: 12)
            .scaleEffect(y: 3, anchor: .center)
            .clipShape(.capsule)
    }
}
