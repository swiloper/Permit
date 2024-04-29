//
//  CircularProgressView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 29.04.2024.
//

import SwiftUI

struct CircularProgressView: View {
    
    // MARK: - Properties
    
    let progress: Double
    let lineWidth: Double
    let foregroundColor: Color
    
    // MARK: - Body
    
    var body: some View {
        Circle()
            .trim(from: .zero, to: progress)
            .stroke(foregroundColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.radians(-.pi / 2))
            .animation(.easeOut, value: progress)
    }
}

// MARK: - Preview

#Preview {
    CircularProgressView(progress: .zero, lineWidth: 6, foregroundColor: .blue)
}
