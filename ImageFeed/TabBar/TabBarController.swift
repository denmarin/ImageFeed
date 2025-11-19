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
		   let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
		   let profileViewController = ProfileViewController()
		   profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabProfileActive"), selectedImage: nil
		   )
		   self.viewControllers = [imagesListViewController, profileViewController]
	   }
   }
	   
