//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 11.11.25.
//

import Foundation
import UIKit

// MARK: - Answer from API
struct ProfileResult: Codable {
    var username: String?
    var firstName: String?
    var lastName: String?
    var bio: String?
    var profileImage: String?
}

final class ProfileService {
    static let shared = ProfileService()
    
    // MARK: - UI Model
    struct Profile {
        var username: String
        var firstName: String
        var lastName: String
        var bio: String
        var profileImage: UIImage

        var name: String { "\(firstName) \(lastName)" }
        var loginName: String { "@\(username)" }
    }
    
    private(set) var profile: Profile?

    // MARK: - API work
    enum ProfileServiceError: Error { case invalidURL, decodingFailed, requestInFlight }
    
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    private func makeProfileRequest(token: String) throws -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/me") else { throw ProfileServiceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchProfile(_ token: String) async throws -> Profile {
        let request = try makeProfileRequest(token: token)
        let (data, _) = try await session.data(for: request)

        let snakeCaseDecoder = JSONDecoder.snakeCase()
        let result = try snakeCaseDecoder.decode(ProfileResult.self, from: data)
        
        let avatarImage: UIImage = UIImage(resource: .profilePic) // placeholder instead of fetching from network

        let profile = Profile(
            username: result.username ?? "",
            firstName: result.firstName ?? "",
            lastName: result.lastName ?? "",
            bio: result.bio ?? "",
            profileImage: avatarImage
        )
        self.profile = profile
        return profile
    }
}

