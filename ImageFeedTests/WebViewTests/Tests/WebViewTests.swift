//
//  WebViewTests.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 02.01.26.

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    // 1) Проверяет, что после presenter.viewDidLoad() у вью вызывается loadRequest
	func testPresenterCallsLoadRequest() async {
		await MainActor.run {
            // Given
			let viewController = WebViewViewControllerSpy()
			let authHelper = AuthHelper(configuration: .standard)
			let presenter = WebViewPresenter(authHelper: authHelper)
			viewController.presenter = presenter
			presenter.view = viewController
			
            // When
			presenter.viewDidLoad()
			
            // Then
			XCTAssertTrue(viewController.loadRequestCalled, "Presenter should ask view to load request on viewDidLoad")
		}
    }
    
    // 2) Если прогресс равен 1.0, метод должен вернуть true (прогресс скрыт)
    func testProgressHiddenWhenOne() {
        // Given
        let progress: Float = 1.0
        
        // When
        let shouldHideProgress = WebViewPresenter.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertTrue(shouldHideProgress, "Progress should be hidden when it reaches 1.0")
    }
    
    // 3) AuthHelper корректно распознаёт код из ссылки
    func testCodeFromURL() async {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
		let authHelper = await MainActor.run {AuthHelper(configuration: .standard)}
        
        // When
		let code = await authHelper.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test code")
    }
}

