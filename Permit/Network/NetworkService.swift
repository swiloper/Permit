//
//  NetworkService.swift
//  Permit
//
//  Created by Ihor Myronishyn on 03.04.2024.
//

import Foundation

enum EndpointPath {
    static let scan = "http://192.168.31.39:8000/scan"
    static let authenticate = "http://192.168.31.39:8000/authenticate"
}

enum HTTPMethod: String {
    case get, put, post, delete
    
    var value: String {
        self.rawValue.uppercased()
    }
}

final class NetworkService {
    
    // MARK: - Properties
    
    enum NetworkRequestError: Error {
        case invalidEndpointPath
        case invalidResponse
        case badStatusCode
        case decodingFailed
    }
    
    static let shared = NetworkService()
    
    // MARK: - Init
    
    private init() {
        // Empty.
    }
    
    // MARK: - Request
    
    func request<T>(link: String, parameters: [String : Any] = [:], method: HTTPMethod, decode decodable: T.Type) async throws -> T where T : Decodable {
        return try await withCheckedThrowingContinuation { continuation in
            if let link = URL(string: link) {
                Task {
                    var request = URLRequest(url: link)
                    request.httpMethod = method.value
                    
                    if !parameters.isEmpty, let data = encode(parameters) {
                        request.httpBody = data
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                    
                    do {
                        let (data, response) = try await URLSession.shared.data(for: request)
                        let range = 200 ..< 300
                        
                        if let response = response as? HTTPURLResponse, range.contains(response.statusCode) {
                            if let result = try? JSONDecoder().decode(T.self, from: data) {
                                continuation.resume(with: .success(result))
                            } else {
                                continuation.resume(with: .failure(NetworkRequestError.decodingFailed))
                            }
                        } else {
                            continuation.resume(with: .failure(NetworkRequestError.badStatusCode))
                        }
                    } catch {
                        continuation.resume(with: .failure(NetworkRequestError.invalidResponse))
                    }
                }
            } else {
                continuation.resume(with: .failure(NetworkRequestError.invalidEndpointPath))
            }
        }
    }
    
    // MARK: - Encode
    
    private func encode(_ parameters: [String : Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: parameters, options: [])
    }
}

