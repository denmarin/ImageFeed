//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 05.11.25.
//

import UIKit

final class SplashViewController: UIViewController {
    private let tokenStorage = OAuth2TokenStorage.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task { [weak self] in
            guard let self else { return }
            let token = await tokenStorage.get()
            if let token {
                await self.fetchProfile(token)
                await self.switchToTabBarController()
            } else {
                self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
            }
        }
    }
    
    private func switchToTabBarController() async {
        await MainActor.run {
            guard
                let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                let window = windowScene.windows.first
            else {
                assertionFailure("Invalid window configuration")
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TapBarViewController")
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    private func fetchProfile(_ token: String) async {
        do {
            let profile = try await profileService.fetchProfile(token)
            Task {
                try? await ProfileImageService.shared.fetchProfileImageURL(username: profile.username)
            }
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) async  {
        vc.dismiss(animated: true)
        let token = await tokenStorage.get()
        if let token {
            await fetchProfile(token)
        }
        await switchToTabBarController()
    }
}

