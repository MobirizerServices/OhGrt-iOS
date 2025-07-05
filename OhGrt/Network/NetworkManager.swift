//
//  NetworkManager.swift
//  OhGrt
//
//  Created by Narendra on 26/04/25.
//

import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private init() {
        // Configure JSON encoder/decoder if needed
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, body: [String: Any]? = nil, token: String? = nil) -> AnyPublisher<T, Error> {
        guard let url = URL(string: endpoint.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Set common headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if token is provided or available in UserDefaults
        if endpoint.path != "/auth/firebase-login" {
            if let token = UserDefaults.standard.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        // Handle request body
        if let body = body {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
            } catch {
                return Fail(error: NetworkError.encodingError(error)).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                print("----- API MESSAGE -----")
                print(request.url?.absoluteString ?? "")
                print(String(data: result.data, encoding: .utf8) ?? "Invalid response data")

                // Handle different status codes
                switch response.statusCode {
                case 200...299:
                    print(String(data: result.data, encoding: .utf8)!)
                    print("-------------------")
                    return result.data
                case 401:
                    // If unauthorized, try to refresh token
                    if let refreshToken = UserDefaults.standard.refreshToken {
                        // TODO: Implement token refresh logic
                        throw NetworkError.unauthorized
                    }
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                case 500...599:
                    throw NetworkError.serverError(response.statusCode)
                default:
                    throw NetworkError.unexpectedStatusCode(response.statusCode)
                }
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(decodingError)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case encodingError(Error)
    case decodingError(DecodingError)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
