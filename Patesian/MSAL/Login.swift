//
//  Login.swift
//  Patesian
//
//  Created by Jimin Lee on 18/02/2024.
//

import Foundation
import SwiftUI

func login(using settings: loginSettings, endpoint: String) async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
        MSALAuthentication.signin { securityToken, isTokenCached, expiresOn in
            if (isTokenCached != nil) && (expiresOn != nil) {
                DispatchQueue.main.async {
                    settings.isAuthenticated = true
                }
                
                guard let url = URL(string: endpoint) else {
                    continuation.resume(throwing: YourError.invalidURL)
                    return
                }
                
                var request = URLRequest(url: url)
                
                request.httpMethod = "GET"
                request.addValue("Bearer \(securityToken!)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200,
                          error == nil else {
                        continuation.resume(throwing: YourError.invalidResponse)
                        return
                    }
                    
                    if let jsonData = data {
                        continuation.resume(returning: jsonData)
                    } else {
                        continuation.resume(throwing: YourError.serializationError)
                    }
                }.resume()
            }
        }
    }
}

// Define your custom error type
enum YourError: Error {
    case invalidURL
    case invalidResponse
    case serializationError
}
