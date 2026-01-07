//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 08.12.25.
//


import Foundation
import WebKit

protocol ProfileLogoutServiceProtocol: AnyObject {
	func logout() async
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()
    private init() { }

    func logout() async {
        cleanCookies()

        Task.detached(priority: .utility) {
            await OAuth2TokenStorage.shared.set(nil)
        }

        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
        
        await MainActor.run {
            guard
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first
            else { return }
            let splash = SplashViewController()
            window.rootViewController = splash
            window.makeKeyAndVisible()
        }
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
    
