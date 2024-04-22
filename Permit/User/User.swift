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
    var isFaceScanned: Bool = false
    var group: String? = nil
}
 
extension User {
    static let empty = User(id: .empty, image: .empty, name: .empty, surname: .empty, email: .empty)
}
