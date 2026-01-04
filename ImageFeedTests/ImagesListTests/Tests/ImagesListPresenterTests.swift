@testable import ImageFeed
import XCTest

final class NoOpHUD: ProgressHUDProviding {
    func show() {}
    func dismiss() {}
}

@MainActor
final class ImagesListPresenterTests: XCTestCase {

    func testDidTapLikeCallsServiceAndReenablesButtonOnSuccess() async {
        // given
        let service = ImagesListServiceFake()
        service.photos = [Photo(id: "1", width: 10, height: 10, createdAt: nil, welcomeDescription: nil, thumbImageURL: nil, regularImageURL: nil, largeImageURL: nil, isLiked: false)]
        let presenter = ImagesListPresenter(imagesListService: service, hud: NoOpHUD())
        let view = ImagesListViewSpy()
        presenter.view = view

        let exp = expectation(description: "Like re-enabled")
        view.onSetLikeEnabled = { enabled, _ in
            if enabled { exp.fulfill() }
        }

        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        // then
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(service.changeLikeCalls.count, 1)
        XCTAssertTrue(view.setLikeEnabledCalls.contains(where: { $0.enabled == true }))
    }
}

final class ImagesListViewSpy: ImagesListViewProtocol {
    private(set) var reloadCalls: [(from: Int, to: Int)] = []
    private(set) var setLikeEnabledCalls: [(enabled: Bool, index: IndexPath)] = []
    private(set) var shownErrors: [String] = []
    var onSetLikeEnabled: ((Bool, IndexPath) -> Void)?

    func reloadRows(from oldCount: Int, to newCount: Int) {
        reloadCalls.append((oldCount, newCount))
    }

    func setLikeEnabled(_ enabled: Bool, at indexPath: IndexPath) {
        setLikeEnabledCalls.append((enabled, indexPath))
        onSetLikeEnabled?(enabled, indexPath)
    }

    func showError(message: String) {
        shownErrors.append(message)
    }
}
