//
//  ImageFeedUITests.swift
//
//  Created by Yury Semenyushkin on 03.10.25.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
	private let app = XCUIApplication()
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app.launch()
	}
	
	func testAuth() throws {
		app.buttons["Authenticate"].tap()
		
		let webView = app.webViews["authWebView"]
		
		XCTAssertTrue(webView.waitForExistence(timeout: 5))

		let loginTextField = webView.descendants(matching: .textField).element
		XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
		
		loginTextField.tap()
		loginTextField.typeText("<email>")
		webView.swipeUp()
		
		let passwordTextField = webView.descendants(matching: .secureTextField).element
		XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
		
		passwordTextField.tap()
		passwordTextField.typeText("<password>")
		webView.swipeUp()
		
		webView.buttons["Login"].tap()
		
		let tablesQuery = app.tables
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		
		XCTAssertTrue(cell.waitForExistence(timeout: 5))
	}

	func testFeed() throws {
		let tablesQuery = app.tables
		
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		cell.swipeUp()
		
		sleep(2)
		
		let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
		
		cellToLike.buttons["likeButton"].tap()
		cellToLike.buttons["likeButton"].tap()
		
		sleep(2)
		
		cellToLike.tap()
		
		sleep(2)
		
		let image = app.scrollViews.images.element(boundBy: 0)
		image.pinch(withScale: 3, velocity: 1)
		image.pinch(withScale: 0.5, velocity: -1)
		
		let navBackButtonWhiteButton = app.buttons["navBackButton"]
		navBackButtonWhiteButton.tap()
	}

	func testProfile() throws {
		sleep(3)
		app.tabBars.buttons.element(boundBy: 1).tap()
	   
		XCTAssertTrue(app.staticTexts["profileNameLabel"].exists)
		XCTAssertTrue(app.staticTexts["profileUsernameLabel"].exists)
		
		app.buttons["profileLogoutButton"].tap()
		
		let logoutAlert = app.alerts["logoutAlert"]
		XCTAssertTrue(logoutAlert.waitForExistence(timeout: 5))
		let yesButton = logoutAlert.buttons.matching(identifier: "logoutAlertYesButton").firstMatch
		XCTAssertTrue(yesButton.exists)
		yesButton.tap()
	}
}

