@testable import ImageFeed
import XCTest
import UIKit

@MainActor
final class ProfilePresenterTests: XCTestCase {

    func testViewDidLoadShowsProfileAndAvatar() {
        // given
        let profileService = ProfileServiceFake()
        profileService.profile = ProfileService.Profile(username: "john", firstName: "John", lastName: "Appleseed", bio: "About", profileImage: UIImage())
        let imageService = ProfileImageServiceFake()
        imageService.avatarURL = "https://example.com/avatar.jpg"
        let logoutService = ProfileLogoutServiceFake()

        let presenter = ProfilePresenter(profileService: profileService, profileImageService: imageService, logoutService: logoutService)
        let view = ProfileViewSpy()
        presenter.view = view

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertEqual(view.shown?.name, "John Appleseed")
        XCTAssertEqual(view.shown?.login, "@john")
        XCTAssertEqual(view.shown?.bio, "About")
        XCTAssertEqual(view.avatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }

    func testDidTapLogoutCallsService() async {
        // given
        let profileService = ProfileServiceFake()
        let imageService = ProfileImageServiceFake()
        let logoutService = ProfileLogoutServiceFake()
        let presenter = ProfilePresenter(profileService: profileService, profileImageService: imageService, logoutService: logoutService)

        // when
        await presenter.didTapLogout()

        // then
        XCTAssertTrue(logoutService.logoutCalled)
    }

    // Helper to peek private property for test only (KVC)
    private func presenterValue<T>(of object: AnyObject, keyPath: String) -> T? {
        return object.value(forKey: keyPath) as? T
    }
}

final class ProfileViewSpy: ProfileViewProtocol {
    private(set) var shown: (name: String, login: String, bio: String)?
    private(set) var avatarURL: URL?

    func show(name: String, login: String, bio: String) {
        shown = (name, login, bio)
    }

    func setAvatar(url: URL?) {
        avatarURL = url
    }
}
