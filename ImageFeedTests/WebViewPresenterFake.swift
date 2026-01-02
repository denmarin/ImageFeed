@testable import ImageFeed
import Foundation

final class WebViewPresenterFake: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    let authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        if let request = authHelper.authRequest() {
            view?.load(request: request)
        }
        // mimic initial progress update behavior, but keep it no-op for safety
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        let shouldHide = WebViewPresenter.shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHide)
    }

    func code(from url: URL) -> String? {
        return authHelper.code(from: url)
    }
}
