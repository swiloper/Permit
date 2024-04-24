//
//  AnyError.swift
//  Permit
//
//  Created by Ihor Myronishyn on 22.04.2024.
//

import Foundation

public enum AnyError: Error {
    case userNotFound, userNotVerified
}

extension AnyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            "Current user not found."
        case .userNotVerified:
            "Your identity could not be verified, you cannot receive the access code."
        }
    }
}
