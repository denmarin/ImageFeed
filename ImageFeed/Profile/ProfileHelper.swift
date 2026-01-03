//
//  ProfileHelper.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.01.26.
//

import Foundation

enum ProfileHelper {
    static func displayName(_ name: String?) -> String {
        let value = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "No name" : value
    }

    static func displayLogin(_ login: String?) -> String {
        let value = login?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "@unknown" : value
    }

    static func displayBio(_ bio: String?) -> String {
        let value = bio?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "—" : value
    }
}
