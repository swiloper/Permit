//
//  EnergyGroup.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

struct EnergyGroup: Identifiable, Codable {
    let id: String
    let name: String
    let details: String
    let location: String
    let created: String
    var members: [User]
}

extension EnergyGroup {
    static let empty = EnergyGroup(id: .empty, name: .empty, details: .empty, location: .empty, created: .empty, members: [])
}
