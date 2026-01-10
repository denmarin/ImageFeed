//
//  Photo.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 10.01.26.
//

import Foundation

struct Photo {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let regularImageURL: String?
    let largeImageURL: String?
    var isLiked: Bool
}
