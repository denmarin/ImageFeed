//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.11.25.
//

import Foundation

final class OAuth2Service {
    
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
        
        /*
         enum CodingKeys: String, CodingKey {
         case accessToken = "access_token"
         case tokenType = "token_type"
         case scope
         case refreshToken = "refresh_token"
         case expiresIn = "expires_in"
         }
         */
    }
    
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
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Failed to build URLRequest for OAuth token request")
            let error = NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось собрать URLRequest"])
            throw error
        }
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let error = NSError(domain: "OAuth2Service", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Сервер вернул статус: \(httpResponse.statusCode)"])
            throw error
        }
        
        let snakeCaseDecoder = JSONDecoder.snakeCase()
        let model: OAuthTokenResponseBody
        do {
            model = try snakeCaseDecoder.decode(OAuthTokenResponseBody.self, from: data)
        } catch {
            print("Decoding OAuthTokenResponseBody failed: \(error)")
            throw error
        }
        
        tokenStorage.token = "\(model.accessToken)"
        return "Bearer \(model.accessToken)"
    }
}

