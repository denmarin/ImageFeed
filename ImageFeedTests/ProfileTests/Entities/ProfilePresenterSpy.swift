@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var viewWillAppearCalled = false
    private(set) var didTapLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func viewWillAppear() {
        viewWillAppearCalled = true
    }

    func didTapLogout() async {
        didTapLogoutCalled = true
    }
}
