//
//  WebViewTests.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 02.01.26.
//


@testable import ImageFeed
import XCTest
@MainActor
final class WebViewTests: XCTestCase {
	
	func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
	}
	
	func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelperFake(configuration: .standard)
        let presenter = WebViewPresenterFake(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(viewController.loadRequestCalled)
	}
	
	func testProgressVisibleWhenLessThenOne() {
		//given
		let progress: Float = 0.6
		
		//when
		let shouldHideProgress = WebViewPresenter.shouldHideProgress(for: progress)
		
		//then
		XCTAssertFalse(shouldHideProgress)
	}
	
	func testProgressHiddenWhenOne() {
		//given
		let progress: Float = 1.0
		
		//when
		let shouldHideProgress = WebViewPresenter.shouldHideProgress(for: progress)
		
		//then
		XCTAssertTrue(shouldHideProgress)
	}
	
	func testAuthHelperAuthURL() {
        
		// given
		let configuration = AuthConfiguration(
			accessKey: "TEST_KEY",
			secretKey: "TEST_SECRET",
			redirectURI: "app://callback",
			accessScope: "public+read_user",
			defaultBaseURL: URL(string: "https://api.unsplash.com")!,
			getMeURL: URL(string: "https://api.unsplash.com/me")!,
			getUserURL: URL(string: "https://api.unsplash.com/users")!,
			unsplashAuthorizeURL: URL(string: "https://unsplash.com/oauth/authorize")!
		)
		
		let authHelper = AuthHelperFake(configuration: configuration)

        // when
        let url = authHelper.authURL()

        // then
        XCTAssertNotNil(url)
        guard let url else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components)
        guard let components else { return }

        // Base URL structure
        let baseURL = configuration.unsplashAuthorizeURL
        if let baseComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) {
            XCTAssertEqual(components.scheme, baseComponents.scheme)
            XCTAssertEqual(components.host, baseComponents.host)
            XCTAssertEqual(components.path, baseComponents.path)
        }

        // Required query items
        let items = components.queryItems ?? []
        func value(_ name: String) -> String? { items.first { $0.name == name }?.value }

        XCTAssertEqual(value("client_id"), configuration.accessKey)
        XCTAssertEqual(value("redirect_uri"), configuration.redirectURI)
        XCTAssertEqual(value("response_type"), "code")
        XCTAssertEqual(value("scope"), configuration.accessScope)
	}
	
	func testCodeFromURL() {
		//given
		var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
		urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
		let url = urlComponents.url!
		let authHelper = AuthHelperFake(configuration: .standard)
		
		//when
		let code = authHelper.code(from: url)
		
		//then
		XCTAssertEqual(code, "test code")
	}
}

