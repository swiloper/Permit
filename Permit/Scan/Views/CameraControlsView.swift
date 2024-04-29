//
//  CameraControlsView.swift
//  Permit
//
//  Created by Ihor Myronishyn on 29.04.2024.
//

import SwiftUI

struct CameraControlsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var model: CameraViewModel
    let dismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer(minLength: .zero)
            cancel
            Spacer(minLength: .zero)
            shutter
            Spacer(minLength: .zero)
            cancel
                .disabled(true)
                .opacity(.zero)
            Spacer(minLength: .zero)
        } //: HStack
        .padding(.vertical, 8)
        .background(.black)
    }
    
    // MARK: - Cancel
    
    private var cancel: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
                .font(.system(size: 20))
                .foregroundStyle(Color.accentColor)
                .frame(height: 44)
                .padding(.horizontal, 16)
                .contentShape(.rect)
        } //: Button
        .buttonStyle(.plain)
    }
    
    // MARK: - Shutter
    
    private var shutter: some View {
        ShutterButton(model: model)
    }
}

// MARK: - Preview

#Preview {
    CameraControlsView(model: CameraViewModel()) {
        print("Dismiss")
    } //: CameraControlsView
}
