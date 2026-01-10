@testable import ImageFeed
import XCTest
import UIKit

@MainActor
final class ImagesListViewControllerTests: XCTestCase {

    private var retainedTableView: UITableView?

    private func makeVC() -> ImagesListViewController {
        let vc = ImagesListViewController(nibName: nil, bundle: nil)
        let tableView = UITableView()
        self.retainedTableView = tableView
        vc.tableView = tableView
        return vc
    }

    func testViewControllerCallsPresenterViewDidLoad() {
        // Given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        vc.configure(presenter)
        // When
        vc.viewDidLoad()
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testNumberOfRowsDelegatesToPresenter() {
        // Given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 3
        vc.configure(presenter)
        // When
        let rows = vc.tableView(vc.tableView!, numberOfRowsInSection: 0)
        // Then
        XCTAssertEqual(rows, 3)
    }

    func testWillDisplayCellCallsPresenter() {
        // Given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        vc.viewDidLoad()
        let tableView = vc.tableView!
        tableView.dataSource = vc
        tableView.delegate = vc
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = UITableViewCell()
        // When
        vc.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        // Then
        XCTAssertTrue(presenter.willDisplayCellCalled)
    }

    func testHeightForRowDelegatesToPresenter() {
        // Given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        vc.viewDidLoad()
        let tableView = vc.tableView!
        // When
        let height = vc.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(presenter.cellHeightCalled)
        XCTAssertEqual(height, 200)
    }

    func testCellForRowAsksPresenterToConfigureCell() {
        // Given
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        let tableView = vc.tableView!
        tableView.dataSource = vc
        tableView.delegate = vc
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        vc.viewDidLoad()
        // When
        let cell = vc.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(presenter.configureCellCalled)
        XCTAssertTrue(cell is ImagesListCell)
    }
}

