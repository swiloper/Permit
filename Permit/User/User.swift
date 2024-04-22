//
//  User.swift
//  Permit
//
//  Created by Ihor Myronishyn on 21.04.2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let image: String
    let name: String
    let surname: String
    let email: String
    var isFaceScanned: Bool
}
