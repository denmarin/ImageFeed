//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 11.11.25.
//

import UIKit

// MARK: - Answer from API
struct ProfileResult: Codable {
    var username: String?
    var firstName: String?
    var lastName: String?
    var bio: String?
}

final class ProfileService {
    static let shared = ProfileService()
    static let didChangeNotification = Notification.Name("ProfileServiceDidChange")
    
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
        do {
            let request = try makeProfileRequest(token: token)
            let result: ProfileResult = try await session.objectTask(for: request, decoder: .snakeCase())
            print("[ProfileService] Fetched profile result: username=\(result.username ?? "nil"), firstName=\(result.firstName ?? "nil"), lastName=\(result.lastName ?? "nil"), bio=\(result.bio ?? "nil")")

            let avatarImage: UIImage = UIImage(resource: .profilePic)

            let profile = Profile(
                username: result.username ?? "",
                firstName: result.firstName ?? "",
                lastName: result.lastName ?? "",
                bio: result.bio ?? "",
                profileImage: avatarImage
            )
            self.profile = profile
            await MainActor.run {
                NotificationCenter.default.post(name: ProfileService.didChangeNotification, object: self)
            }
            return profile
        } catch {
            print("[ProfileService.fetchProfile]: \(error.localizedDescription)")
            throw error
        }
    }
}

