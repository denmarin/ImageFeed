//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.11.25.
//

import Foundation

enum OAuthError: LocalizedError {
    case invalidRequest
    case nonHTTPResponse
    case badStatus(code: Int, body: Data?)
    case decodingFailed(underlying: Error)
    case transport(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Не удалось собрать запрос авторизации."
        case .nonHTTPResponse:
            return "Некорректный ответ сервера."
        case .badStatus(let code, _):
            return "Сервер вернул статус \(code)."
        case .decodingFailed:
            return "Не удалось обработать ответ сервера."
        case .transport:
            return "Проблема сети или соединения."
        }
    }
}

actor OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let tokenURLString = Constants.defaultBaseURL
    private let clientID = Constants.accessKey
    private let clientSecret = Constants.secretKey
    private let redirectURI = Constants.redirectURI
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String?
        let scope: String?
        let refreshToken: String?
        let expiresIn: Int?
    }
    
    private var inFlight: (code: String, task: Task<String, Error>)?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Failed to create URL for OAuth token endpoint")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let items = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        
        var components = URLComponents()
        components.queryItems = items
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        return request
    }
    
    func fetchOAuthToken(code: String) async throws -> String {
        if let current = inFlight {
            if current.code == code {
                return try await current.task.value
            } else {
                current.task.cancel()
                inFlight = nil
            }
        }
        
        let task = Task<String, Error> {
            guard let request = makeOAuthTokenRequest(code: code) else {
                throw OAuthError.invalidRequest
            }
            
            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await URLSession.shared.data(for: request)
            } catch {
                throw OAuthError.transport(underlying: error)
            }
            
            guard let http = response as? HTTPURLResponse else {
                throw OAuthError.nonHTTPResponse
            }
            
            guard (200...299).contains(http.statusCode) else {
                throw OAuthError.badStatus(code: http.statusCode, body: data)
            }
            
            let decoder = JSONDecoder.snakeCase()
            let model: OAuthTokenResponseBody
            do {
                model = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            } catch {
                throw OAuthError.decodingFailed(underlying: error)
            }
            
            await tokenStorage.set(model.accessToken)
            return "Bearer \(model.accessToken)"
        }
        
        inFlight = (code, task)
        
        do {
            let result = try await task.value
            inFlight = nil
            return result
        } catch {
            inFlight = nil
            throw error
        }
    }
}

