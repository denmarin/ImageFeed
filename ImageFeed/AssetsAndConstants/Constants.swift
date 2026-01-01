//
//  Constants.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 25.10.25.
//

import Foundation

nonisolated enum Constants {
    public static let accessKey = "0AFUCt3eiA-KgxWWymbCKHuXrBHz9ekf0qVytN75sqU"
    public static let secretKey = "97reZ7soU27DzlttbsBahlFnZ4gNxTXlIR7LdW472KU"
    public static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    public static let accessScope = "public+read_user+write_likes"

    private static func makeURL(named name: String, string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw AuthConfigurationError.invalidURL(name: name, string: string)
        }
        return url
    }

    public static let defaultBaseURL: URL = try! makeURL(named: "defaultBaseURL", string: "https://api.unsplash.com")
    public static let getMeURL: URL = try! makeURL(named: "getMeURL", string: "https://api.unsplash.com/me")
    public static let getUserURL: URL = try! makeURL(named: "getUserURL", string: "https://api.unsplash.com/users/")
    public static let unsplashAuthorizeURL: URL = try! makeURL(named: "unsplashAuthorizeURL", string: "https://unsplash.com/oauth/authorize")
}

struct AuthConfiguration {
	let accessKey: String
	let secretKey: String
	let redirectURI: String
	let accessScope: String
	let defaultBaseURL: URL
	let getMeURL: URL
	let getUserURL: URL
	let unsplashAuthorizeURL: URL

	init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, getMeURL: URL, getUserURL: URL, unsplashAuthorizeURL: URL) {
		self.accessKey = accessKey
		self.secretKey = secretKey
		self.redirectURI = redirectURI
		self.accessScope = accessScope
		self.defaultBaseURL = defaultBaseURL
		self.getMeURL = getMeURL
		self.getUserURL = getUserURL
		self.unsplashAuthorizeURL = unsplashAuthorizeURL
	}
	static var standard: AuthConfiguration {
			return AuthConfiguration(accessKey: Constants.accessKey,
									 secretKey: Constants.secretKey,
									 redirectURI: Constants.redirectURI,
									 accessScope: Constants.accessScope,
									 defaultBaseURL: Constants.defaultBaseURL,
									 getMeURL: Constants.getMeURL,
									 getUserURL: Constants.getUserURL,
									 unsplashAuthorizeURL: Constants.unsplashAuthorizeURL)
	}
}

enum AuthConfigurationError: LocalizedError {
    case invalidURL(name: String, string: String)

    var errorDescription: String? {
        switch self {
        case let .invalidURL(name, string):
            return "Invalid URL for \(name): \(string)"
        }
    }
}
