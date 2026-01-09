@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?

    var numberOfRows: Int = 0

    private(set) var viewDidLoadCalled = false
    private(set) var willDisplayCellCalled = false
    private(set) var configureCellCalled = false
    private(set) var cellHeightCalled = false
    private(set) var didTapLikeCalled = false
    private(set) var imageURLForDetailsCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }

    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        configureCellCalled = true
    }

    func cellHeight(for tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        cellHeightCalled = true
        return 200
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }

    func imageURLForDetails(at indexPath: IndexPath) -> URL? {
        imageURLForDetailsCalled = true
        return URL(string: "https://example.com/image.jpg")
    }
}
