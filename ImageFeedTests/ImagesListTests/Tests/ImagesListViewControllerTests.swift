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
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        vc.configure(presenter)
        vc.viewDidLoad()
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testNumberOfRowsDelegatesToPresenter() {
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 3
        vc.configure(presenter)
        let rows = vc.tableView(vc.tableView!, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 3)
    }

    func testWillDisplayCellCallsPresenter() {
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
        vc.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        XCTAssertTrue(presenter.willDisplayCellCalled)
    }

    func testHeightForRowDelegatesToPresenter() {
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        vc.viewDidLoad()
        let tableView = vc.tableView!
        let height = vc.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(presenter.cellHeightCalled)
        XCTAssertEqual(height, 200)
    }

    func testCellForRowAsksPresenterToConfigureCell() {
        let vc = makeVC()
        let presenter = ImagesListPresenterSpy()
        presenter.numberOfRows = 1
        vc.configure(presenter)
        let tableView = vc.tableView!
        tableView.dataSource = vc
        tableView.delegate = vc
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        vc.viewDidLoad()
        let cell = vc.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(presenter.configureCellCalled)
        XCTAssertTrue(cell is ImagesListCell)
    }
}

