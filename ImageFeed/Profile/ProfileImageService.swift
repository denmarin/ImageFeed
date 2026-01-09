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

protocol ProfileImageServiceProtocol: AnyObject {
	var avatarURL: String? { get }
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
	private let tokenStorage = OAuth2TokenStorage.shared
    
    // Ответ API
    struct UserResult: Codable {
        let profileImage: ProfileImage
		
		struct ProfileImage: Codable {
			let small: String
			let medium: String
			let large: String
		}
    }

    

    @discardableResult
    func fetchProfileImageURL(username: String) async throws -> String {
        let request = try await makeRequest(username: username)
        do {
            let result: UserResult = try await URLSession.shared.objectTask(for: request)
            let url = result.profileImage.large
            self.avatarURL = url
			await MainActor.run {
				NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": url])
			}
            return url
        } catch {
            print("[ProfileImageService.fetchProfileImageURL]: \(error.localizedDescription)")
            throw error
        }
    }

    private func makeRequest(username: String) async throws -> URLRequest {
		guard !username.isEmpty else {
			throw ProfileImageError.invalidURL
		}
		
		let baseURL = Constants.getUserURL
		let url = baseURL.appendingPathComponent(username)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let token = await tokenStorage.get()

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    func reset() {
        avatarURL = nil
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
    }
}
