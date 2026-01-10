@testable import ImageFeed
import XCTest

@MainActor
final class ProfileViewControllerTests: XCTestCase {

    func testViewControllerCallsPresenterViewDidLoad() {
        // Given
        let vc = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        vc.configure(presenter)

        // When
        vc.loadViewIfNeeded()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewControllerCallsPresenterViewWillAppear() {
        // Given
        let vc = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        vc.configure(presenter)
        vc.loadViewIfNeeded()

        // When
        vc.viewWillAppear(false)

        // Then
        XCTAssertTrue(presenter.viewWillAppearCalled)
    }
}
