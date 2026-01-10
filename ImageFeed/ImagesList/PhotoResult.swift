//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 10.01.26.
//

import Foundation

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
