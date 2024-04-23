//
//  Entry.swift
//  Permit
//
//  Created by Ihor Myronishyn on 23.04.2024.
//

import Foundation
import FirebaseFirestore

struct Entry: Identifiable, Codable {
    let id: String
    let user: User
    let timestamp: Timestamp
    
    var date: Date {
        timestamp.dateValue()
    }
}
