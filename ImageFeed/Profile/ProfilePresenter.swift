//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.01.26.
//

import Foundation
import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private var notificationsTask: Task<Void, Never>?

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }

    func viewDidLoad() {
        if !RuntimeEnvironment.isUnitTesting {
            bindNotifications()
        }
        updateProfile()
        updateAvatar()
    }

    func viewWillAppear() {
        updateProfile()
    }

    func didTapLogout() async {
        await logoutService.logout()
    }

    private func bindNotifications() {
        notificationsTask?.cancel()
        notificationsTask = Task { [weak self] in
            guard let self else { return }
            for await _ in NotificationCenter.default.notifications(named: ProfileImageService.didChangeNotification, object: nil) {
                await MainActor.run { self.updateAvatar() }
            }
            for await _ in NotificationCenter.default.notifications(named: ProfileService.didChangeNotification, object: nil) {
                await MainActor.run { self.updateProfile() }
            }
        }
    }

    private func updateProfile() {
        guard let profile = profileService.profile else { return }
        view?.show(name: profile.name, login: profile.loginName, bio: profile.bio)
    }

    private func updateAvatar() {
        guard let urlString = profileImageService.avatarURL, let url = URL(string: urlString) else {
            view?.setAvatar(url: nil)
            return
        }
        view?.setAvatar(url: url)
    }

    deinit {
        notificationsTask?.cancel()
    }
}

