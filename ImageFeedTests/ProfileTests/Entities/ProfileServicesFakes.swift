@testable import ImageFeed
import UIKit

final class ProfileServiceFake: ProfileServiceProtocol {
    var profile: ProfileService.Profile?
}

final class ProfileImageServiceFake: ProfileImageServiceProtocol {
    var avatarURL: String?
}

final class ProfileLogoutServiceFake: ProfileLogoutServiceProtocol {
    private(set) var logoutCalled = false
    func logout() async { logoutCalled = true }
}
