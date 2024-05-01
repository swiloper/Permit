//
//  Watch.swift
//  Permit
//
//  Created by Ihor Myronishyn on 01.05.2024.
//

import Foundation

final class Watch: ObservableObject {
    
    // MARK: - Properties
    
    @Published var remains: Double = 60000
    private var timer = Timer()
    
    // MARK: - Methods
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
            self.remains -= 1
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func reset() {
        remains = 60000
        timer.invalidate()
    }
}
