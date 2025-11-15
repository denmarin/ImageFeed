//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 15.11.25.
//

import Foundation

private enum ProfileImageError: LocalizedError {
    case invalidURL
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .badStatus(let code): return "Bad status: \(code)"
        }
    }
}

final class ProfileImageService {
    // Ответ API
    struct UserResult: Codable {
        let profileImage: ProfileImage
        enum CodingKeys: String, CodingKey { case profileImage = "profile_image" }
    }

    struct ProfileImage: Codable { let small: String }

    static let shared = ProfileImageService()
    private init() {}

    private(set) var avatarURL: String?

    @discardableResult
    func fetchProfileImageURL(username: String) async throws -> String {
        let request = try await makeRequest(username: username)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw ProfileImageError.badStatus(status)
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(UserResult.self, from: data)
        let url = result.profileImage.small
        self.avatarURL = url
        return url
    }

    private func makeRequest(username: String) async throws -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            throw ProfileImageError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let token = await OAuth2TokenStorage.shared.get()

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}

