//
//  AnyError.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

public enum AnyError: Error {
    case userNotFound
}

extension AnyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            "Current user not found."
        }
    }
}
