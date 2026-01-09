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
        imagesListVC.tabBarItem.accessibilityLabel = "feedTab"
        // Profile
        let profileVC = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileVC.configure(profilePresenter)
        let profileItem = UITabBarItem(title: nil, image: UIImage(resource: .tabProfileActive), selectedImage: nil)
        profileItem.accessibilityIdentifier = "profileTab"
        profileItem.accessibilityLabel = "profileTab"
        profileItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileItem

        self.viewControllers = [imagesListVC, profileVC]
    }
}

