//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 11.10.25.
//

import UIKit
import Kingfisher

// MARK: - Protocols
protocol ProfileViewProtocol: AnyObject {
    func show(name: String, login: String, bio: String)
    func setAvatar(url: URL?)
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didTapLogout() async
}

// MARK: - View Controller
final class ProfileViewController: UIViewController, ProfileViewProtocol {
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var imageView: UIImageView!

    private var presenter: ProfilePresenterProtocol?

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack

        addProfilePicture()
        addNameLabel()
        addNicknameLabel()
        addDescriptionLabel()
        addExitButton()

        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    // MARK: - ProfileViewProtocol
    func show(name: String, login: String, bio: String) {
        nameLabel?.text = name.isEmpty ? "No name" : name
        nicknameLabel?.text = login.isEmpty ? "@unknown" : login
        descriptionLabel?.text = bio.isEmpty ? "—" : bio
    }

    func setAvatar(url: URL?) {
        let placeholder = UIImage(resource: .profilePic)
        if let url {
            imageView.kf.setImage(with: url, placeholder: placeholder, options: [.cacheOriginalImage])
        } else {
            imageView.image = placeholder
        }
    }

    // MARK: - UI
    private func addProfilePicture() {
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

    private func addNameLabel () {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.text = "No name"
        nameLabel.accessibilityIdentifier = "profileNameLabel"
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8)
        ])
        self.nameLabel = nameLabel
    }

    private func addNicknameLabel() {
        let nicknameLabel = UILabel()
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.textColor = .ypGray
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nicknameLabel.text = "@unknown"
        nicknameLabel.accessibilityIdentifier = "profileUsernameLabel"
        view.addSubview(nicknameLabel)
        NSLayoutConstraint.activate([
            nicknameLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: self.nameLabel?.bottomAnchor ?? self.imageView.bottomAnchor, constant: 8)
        ])
        self.nicknameLabel = nicknameLabel
    }

    private func addDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.text = "—"
        descriptionLabel.accessibilityIdentifier = "profileBioLabel"
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.nicknameLabel?.bottomAnchor ?? self.imageView.bottomAnchor, constant: 8)
        ])
        self.descriptionLabel = descriptionLabel
    }

    private func addExitButton () {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.accessibilityIdentifier = "profileLogoutButton"
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
            let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
            alert.view.accessibilityIdentifier = "logoutAlert"

            let yes = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                guard let self else { return }
                Task { await self.presenter?.didTapLogout() }
            }
            yes.setValue("logoutAlertYesButton", forKey: "accessibilityIdentifier")
            yes.setValue(UIColor.systemBlue, forKey: "titleTextColor")

            let no = UIAlertAction(title: "Нет", style: .default)
            no.setValue("logoutAlertNoButton", forKey: "accessibilityIdentifier")
            no.setValue(UIColor.systemBlue, forKey: "titleTextColor")

            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true)
        }, for: .touchUpInside)
    }
}

