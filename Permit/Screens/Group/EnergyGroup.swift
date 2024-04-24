//
//  EnergyGroup.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

struct EnergyGroup: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var details: String
    var location: String
    let created: String
    var members: [User]
}

extension EnergyGroup {
    static let empty = EnergyGroup(id: .empty, name: .empty, details: .empty, location: .empty, created: .empty, members: [])
}
