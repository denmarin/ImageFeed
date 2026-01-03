//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 19.11.25.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        // Images List
        guard let imagesListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            assertionFailure("Failed to instantiate ImagesListViewController")
            return
        }
        let imagesPresenter = ImagesListPresenter()
        imagesListVC.configure(imagesPresenter)
        // Profile
        let profileVC = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileVC.configure(profilePresenter)
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(resource: .tabProfileActive), selectedImage: nil)

        self.viewControllers = [imagesListVC, profileVC]
    }
}

