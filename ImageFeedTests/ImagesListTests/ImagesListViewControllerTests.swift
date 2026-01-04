@testable import ImageFeed
import XCTest
import UIKit

@MainActor
final class ImagesListViewControllerTests: XCTestCase {

    private func makeVC() -> ImagesListViewController {
        let vc = ImagesListViewController(nibName: nil, bundle: nil)
        // Load view hierarchy so we can safely add subviews
        vc.loadViewIfNeeded()
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        vc.view.addSubview(tableView)
        vc.tableView = tableView
        return vc
    }

    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        vc.configure(presenter)

        // when
        vc.viewDidLoad()

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testNumberOfRowsDelegatesToPresenter() {
        // given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 3
        vc.configure(presenter)

        // when
        let rows = vc.tableView(vc.tableView!, numberOfRowsInSection: 0)

        // then
        XCTAssertEqual(rows, 3)
    }

    func testWillDisplayCellCallsPresenter() {
        // given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        vc.viewDidLoad()

        let tableView = vc.tableView!
        tableView.dataSource = vc
        tableView.delegate = vc

        // when
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = UITableViewCell()
        vc.tableView(tableView, willDisplay: cell, forRowAt: indexPath)

        // then
        XCTAssertTrue(presenter.willDisplayCellCalled)
    }

    func testHeightForRowDelegatesToPresenter() {
        // given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        vc.viewDidLoad()

        let tableView = vc.tableView!

        // when
        let height = vc.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))

        // then
        XCTAssertTrue(presenter.cellHeightCalled)
        XCTAssertEqual(height, 200)
    }

    func testCellForRowAsksPresenterToConfigureCell() {
        // given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)

        let tableView = vc.tableView!
        tableView.dataSource = vc
        tableView.delegate = vc
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)

        vc.viewDidLoad()

        // when
        let cell = vc.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        // then
        XCTAssertTrue(presenter.configureCellCalled)
        XCTAssertTrue(cell is ImagesListCell)
    }
}

