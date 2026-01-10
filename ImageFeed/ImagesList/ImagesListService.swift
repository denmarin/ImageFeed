//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 28.11.25.

import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool) async throws -> Bool
}

final class ImagesListService: ImagesListServiceProtocol {

    static let shared = ImagesListService()
    
    private let session: URLSession
    private let tokenStorage: OAuth2TokenStorage

    private init(session: URLSession = .shared, tokenStorage: OAuth2TokenStorage = .shared) {
        self.session = session
        self.tokenStorage = tokenStorage
    }
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var isLoading: Bool = false
    private var didReachEnd: Bool = false
    private let perPage: Int = 10
    
    private(set) var photos: [Photo] = []
    private(set) var lastLoadedPage: Int = 0

    @discardableResult
    func changeLike(photoId: String, isLike: Bool) async throws -> Bool {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            throw ImagesListError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        if let token = await tokenStorage.token, !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw ImagesListError.unauthorized
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ImagesListError.nonHTTPResponse }
            guard (200..<300).contains(http.statusCode) else {
                let body = String(data: data, encoding: .utf8)
                #if DEBUG
                if let body { print("changeLike failed: status=\(http.statusCode) body=\(body)") }
                #endif
                throw ImagesListError.badStatus(code: http.statusCode, body: body)
            }
        } catch {
            throw ImagesListError.transport(underlying: error)
        }

        await MainActor.run {
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                self.photos[index].isLiked = isLike
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            }
        }
        return isLike
    }

    
    func fetchPhotosNextPage() {

        Task { [weak self] in
            guard let self = self else { return }

            let nextPage = await MainActor.run { () -> Int? in
                if self.isLoading { return nil }
                if self.didReachEnd { return nil }
                // Respect UI Tests page limit if provided
                if let maxPages = RuntimeEnvironment.uiTestsMaxPages, self.lastLoadedPage >= maxPages {
                    self.didReachEnd = true
                    return nil
                }
                self.isLoading = true
                return self.lastLoadedPage + 1
            }
            guard let nextPage else { return }
            
            guard var components = URLComponents(string: "https://api.unsplash.com/photos/random") else {
                await MainActor.run { self.isLoading = false }
                return
            }
            components.queryItems = [
                URLQueryItem(name: "count", value: String(self.perPage))
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
                guard let http = response as? HTTPURLResponse else {
                    throw ImagesListError.nonHTTPResponse
                }
                guard (200..<300).contains(http.statusCode) else {
                    let body = String(data: data, encoding: .utf8)
                    #if DEBUG
                    if let body { print("fetchPhotosNextPage failed: status=\(http.statusCode) body=\(body)") }
                    #endif
                    throw ImagesListError.badStatus(code: http.statusCode, body: body)
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
                    // If we have a UI tests page limit and reached it, stop further loading
                    if let maxPages = RuntimeEnvironment.uiTestsMaxPages, self.lastLoadedPage >= maxPages {
                        self.didReachEnd = true
                    }
                    self.isLoading = false
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            } catch {
                await MainActor.run { self.isLoading = false }
                let err = (error as? ImagesListError) ?? .transport(underlying: error)
                print("fetchPhotosNextPage error:", err.localizedDescription)
            }
        }
    }

    func reset() {
        photos.removeAll()
        lastLoadedPage = 0
        isLoading = false
        didReachEnd = false
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
}






