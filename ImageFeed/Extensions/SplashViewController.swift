//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 05.11.25.

import UIKit

final class SplashViewController: UIViewController {
    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "splashScreenLogo"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupLogo()
    }

    private func setupLogo() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task { [weak self] in
            guard let self else { return }
            let token = await self.tokenStorage.get()
            if let token {
                await self.fetchProfile(token)
                await self.switchToTabBarController()
            } else {
                await self.presentAuthViewController()
            }
        }
    }
    
    private func presentAuthViewController() async {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let nav = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController else {
            assertionFailure("Не удалось найти AuthNavigationController по идентификатору")
            return
        }
        if let authVC = nav.viewControllers.first as? AuthViewController {
            authVC.delegate = self
        }
        nav.modalPresentationStyle = .fullScreen
        await MainActor.run {
            self.present(nav, animated: true)
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
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    private func fetchProfile(_ token: String) async {
        do {
            let profile = try await profileService.fetchProfile(token)
            Task(priority: .userInitiated) { [weak self] in
                try? await self?.profileImageService.fetchProfileImageURL(username: profile.username)
            }
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) async  {
        Task { [weak self, weak vc] in
            vc?.dismiss(animated: true)
            guard let self else { return }
            let token = await self.tokenStorage.get()
            if let token {
                await self.fetchProfile(token)
            }
            await self.switchToTabBarController()
        }
    }
}

