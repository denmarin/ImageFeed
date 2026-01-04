//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 02.01.26.
//


import Foundation
@testable import ImageFeed

final class AuthHelperFake: AuthHelperProtocol {
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest? {
        guard var comps = URLComponents(url: configuration.unsplashAuthorizeURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        comps.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        guard let url = comps.url else { return nil }
        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard var comps = URLComponents(url: configuration.unsplashAuthorizeURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        comps.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return comps.url
    }

    func code(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }
}
