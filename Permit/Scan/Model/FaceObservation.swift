//
//  FaceObservation.swift
//  Permit
//
//  Created by Ihor Myronishyn on 28.04.2024.
//

import Foundation

enum FaceObservation<T> {
    case faceFound(T)
    case faceNotFound
    case errored(Error)
}
