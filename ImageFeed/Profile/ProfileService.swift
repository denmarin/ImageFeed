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

    // MARK: - API work
    enum ProfileServiceError: Error { case invalidURL, decodingFailed, requestInFlight }
    
    private let session: URLSession

    init(session: URLSession = .shared) {
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
        
        let avatarURLString = result.profileImage ?? ""
        let avatarImage: UIImage
        if let url = URL(string: avatarURLString), !avatarURLString.isEmpty {
            do {
                let (imageData, _) = try await session.data(from: url)
                if let img = UIImage(data: imageData) {
                    avatarImage = img
                } else {
                    avatarImage = UIImage(resource: .profilePic)
                }
            } catch {
                avatarImage = UIImage(resource: .profilePic)
            }
        } else {
            avatarImage = UIImage(resource: .profilePic)
        }

        let profile = Profile(
            username: result.username ?? "",
            firstName: result.firstName ?? "",
            lastName: result.lastName ?? "",
            bio: result.bio ?? "",
            profileImage: avatarImage
        )
        return profile
    }
}

