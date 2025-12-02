//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 28.11.25.
//

import Foundation

final class ImagesListService {

    private let session: URLSession
    private let tokenStorage: OAuth2TokenStorage

    init(session: URLSession = .shared, tokenStorage: OAuth2TokenStorage = .shared) {
        self.session = session
        self.tokenStorage = tokenStorage
    }
	
	static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	
	private var isLoading: Bool = false
	
	private(set) var photos: [Photo] = []
	private(set) var lastLoadedPage: Int = 0
	
	func fetchPhotosNextPage() {

		Task { [weak self] in
			guard let self = self else { return }

			let nextPage = await MainActor.run { () -> Int? in
				// Checking if the task is ongoing
				if self.isLoading { return nil }
				self.isLoading = true
				return self.lastLoadedPage + 1
			}
			guard let nextPage else { return }
			
			guard var components = URLComponents(string: "https://api.unsplash.com/photos") else {
				await MainActor.run { self.isLoading = false }
				return
			}
			components.queryItems = [
				URLQueryItem(name: "page", value: String(nextPage)),
				URLQueryItem(name: "per_page", value: "10")
			]
			guard let url = components.url else {
				await MainActor.run { self.isLoading = false }
				return
			}

			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			if let token = await tokenStorage.token, !token.isEmpty {
				  request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			  } else {
				  await MainActor.run { self.isLoading = false }
				  print("No auth token available")
				  return
			  }

			do {
				let (data, response) = try await session.data(for: request)
				guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
					throw URLError(.badServerResponse)
				}

				let decoder = JSONDecoder.snakeCase()
				decoder.dateDecodingStrategy = .iso8601

				let results = try decoder.decode([PhotoResult].self, from: data)

				var mapped: [Photo] = []
				mapped.reserveCapacity(results.count)
				for item in results {
					let id = item.id ?? ""
					let width = item.width ?? 0
					let height = item.height ?? 0

					let thumb = item.urls.thumb ?? ""
					let regular = item.urls.regular ?? ""
					let large = item.urls.full ?? ""

					let thumbImageURL = thumb
					let regularImageURL = regular
					let largeImageURL = large

					let photo = Photo(
						id: id,
						width: width,
						height: height,
						createdAt: item.createdAt,
						welcomeDescription: item.description,
						thumbImageURL: thumbImageURL,
						regularImageURL: regularImageURL,
						largeImageURL: largeImageURL,
						isLiked: item.likedByUser ?? false
					)
					mapped.append(photo)
				}

				await MainActor.run {
					self.photos.append(contentsOf: mapped)
					self.lastLoadedPage = nextPage
					self.isLoading = false
					NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
				}
			} catch {
				await MainActor.run {
					self.isLoading = false
				}
				print("fetchPhotosNextPage error:", error)
			}
		}
	}

}

struct PhotoResult: Codable {
	let id: String?
	let createdAt: Date?
	let width: Int?
	let height: Int?
	let color: String?
	let blurHash: String?
	let likes: Int?
	let likedByUser: Bool?
	let description: String?
	let urls: UrlsResult

	struct UrlsResult: Codable {
		let raw: String?
		let full: String?
		let regular: String?
		let small: String?
		let thumb: String?
	}
}

struct Photo {
	let id: String
	let width: Int
	let height: Int
	let createdAt: Date?
	let welcomeDescription: String?
	let thumbImageURL: String?
	let regularImageURL: String?
	let largeImageURL: String?
	let isLiked: Bool
}
