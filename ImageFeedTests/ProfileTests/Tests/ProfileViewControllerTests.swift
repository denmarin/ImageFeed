@testable import ImageFeed
import XCTest

@MainActor
final class ProfileViewControllerTests: XCTestCase {

    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let vc = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        vc.configure(presenter)

        // when
        vc.loadViewIfNeeded()

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewControllerCallsPresenterViewWillAppear() {
        // given
        let vc = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        vc.configure(presenter)
        vc.loadViewIfNeeded()

        // when
        vc.viewWillAppear(false)

        // then
        XCTAssertTrue(presenter.viewWillAppearCalled)
    }
}
