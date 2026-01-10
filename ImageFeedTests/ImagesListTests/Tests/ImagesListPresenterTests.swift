@testable import ImageFeed
import XCTest



@MainActor
final class ImagesListPresenterTests: XCTestCase {

    func testDidTapLikeCallsServiceAndReenablesButtonOnSuccess() async {
        // Given
        let service = ImagesListServiceFake()
        service.photos = [Photo(id: "1", width: 10, height: 10, createdAt: nil, welcomeDescription: nil, thumbImageURL: nil, regularImageURL: nil, largeImageURL: nil, isLiked: false)]
        let presenter = ImagesListPresenter(imagesListService: service, hud: NoOpHUD())
        let view = ImagesListViewSpy()
        presenter.view = view

        let exp = expectation(description: "Like re-enabled")
        view.onSetLikeEnabled = { enabled, _ in
            if enabled { exp.fulfill() }
        }

        // When
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        // Then
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(service.changeLikeCalls.count, 1)
        XCTAssertTrue(view.setLikeEnabledCalls.contains(where: { $0.enabled == true }))
    }
}
