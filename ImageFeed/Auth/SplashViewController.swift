//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 05.11.25.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.token != nil {
            Task {
                await switchToTabBarController()
            }
        } else {
            performSegue(withIdentifier: "\(showAuthenticationScreenSegueIdentifier)", sender: nil)
        }
    }
    
    private func switchToTabBarController() async {
        await MainActor.run {
            guard
                let windowScene = view.window?.windowScene,
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
            await switchToTabBarController()
    }
}

