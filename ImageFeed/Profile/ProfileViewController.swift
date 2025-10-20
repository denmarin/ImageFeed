//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 11.10.25.
//

import UIKit

class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        addProfilePicture()
        addNameLabel()
        addNicknameLabel()
        addDescriptionLabel()
        addExitButton()
        
    }
    
    func addProfilePicture() {
        let profileImage = UIImage(systemName: "person.crop.circle.fill")
        let imageView = UIImageView(image: profileImage)
        self.imageView = imageView
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func addNameLabel () {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .ypWhite

        let text = "Екатерина Новикова"
        nameLabel.text = text
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
        nicknameLabel.textColor = .ypWhite
        
        nicknameLabel.text = "@ekaterina_nov"
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
        descriptionLabel.textColor = .ypGray
        
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.nicknameLabel?.bottomAnchor ?? self.imageView.bottomAnchor, constant: 8)
        ])
        self.descriptionLabel = descriptionLabel
    }
    
    func addExitButton () {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor)
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
}

