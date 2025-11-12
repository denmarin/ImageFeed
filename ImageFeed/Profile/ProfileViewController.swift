//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 11.10.25.
//

import UIKit

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var imageView: UIImageView!
    private let profileService = ProfileService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        addProfilePicture()
        addNameLabel()
        addNicknameLabel()
        addDescriptionLabel()
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let token = await OAuth2TokenStorage.shared.token
                let profile = try await self.profileService.fetchProfile(token ?? "")
                await MainActor.run {
                    self.updateUI(with: profile)
                }
            } catch {
                print("Failed to fetch profile: \(error)")
            }
        }
        addExitButton()
    }
    
    func addProfilePicture() {
        let imageView = UIImageView(image: UIImage(resource: .profilePic))
        self.imageView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func addNameLabel () {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8)
        ])
        self.nameLabel = nameLabel
    }
    
    func addNicknameLabel() {
        let nicknameLabel = UILabel()
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.textColor = .ypGray
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.addSubview(nicknameLabel)
        NSLayoutConstraint.activate([
            nicknameLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: self.nameLabel?.bottomAnchor ?? self.imageView.bottomAnchor, constant: 8)
        ])
        self.nicknameLabel = nicknameLabel
    }
    
    func addDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.nicknameLabel?.bottomAnchor ?? self.imageView.bottomAnchor, constant: 8)
        ])
        self.descriptionLabel = descriptionLabel
    }
    
    func addExitButton () {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if let label = self.nameLabel {
                label.removeFromSuperview()
                self.nameLabel = nil
            }
            if let label = self.nicknameLabel {
                label.removeFromSuperview()
                self.nicknameLabel = nil
            }
            if let label = self.descriptionLabel {
                label.removeFromSuperview()
                self.descriptionLabel = nil
            }
        }, for: .touchUpInside)
    }
    
    private func updateUI(with profile: ProfileService.Profile) {
        nameLabel?.text = profile.name
        nicknameLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio
        imageView.image = profile.profileImage
    }
}
