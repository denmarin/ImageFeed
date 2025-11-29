//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Yury Semenyushkin on 03.10.25.
//
/*
import XCTest
@testable import ImageFeed

final class ImageFeedTests: XCTestCase {
	func testFetchPhotos() async throws {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)

		let items: [[String: Any]] = (0..<10).map { idx in
			return [
				"id": "id_\(idx)",
				"created_at": "2024-01-01T00:00:00Z",
				"width": 1000,
				"height": 800,
				"color": "#FFFFFF",
				"blur_hash": "",
				"likes": 0,
				"liked_by_user": false,
				"description": "desc_\(idx)",
				"urls": [
					"raw": "https://example.com/raw_\(idx)",
					"full": "https://example.com/full_\(idx)",
					"regular": "https://example.com/regular_\(idx)",
					"small": "https://example.com/small_\(idx)",
					"thumb": "https://example.com/thumb_\(idx)"
				]
			]
		}
		let data = try JSONSerialization.data(withJSONObject: items, options: [])

		MockURLProtocol.requestHandler = { (request: URLRequest) in
			let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
			return (response, data)
		}

		await OAuth2TokenStorage.shared.set("TEST_TOKEN")

		let service = ImagesListService(session: session, tokenStorage: .shared)

		let expectation = self.expectation(description: "Wait for Notification")
		let observer = NotificationCenter.default.addObserver(
			forName: ImagesListService.didChangeNotification,
			object: service,
			queue: .main
		) { _ in
			expectation.fulfill()
		}
		defer { NotificationCenter.default.removeObserver(observer) }

		service.fetchPhotosNextPage()
		wait(for: [expectation], timeout: 2)

		XCTAssertEqual(service.photos.count, 10)
	}
}
*/
