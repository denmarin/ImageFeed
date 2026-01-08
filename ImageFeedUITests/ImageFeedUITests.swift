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
        // Limit pages to 1 for UI tests to avoid excessive pagination
        app.launchArguments.append("UITESTING")
        app.launchEnvironment["UITESTS_MAX_PAGES"] = "1"
        app.launch()
	}
	
	func testAuth() throws {
		app.buttons["Authenticate"].tap()
		
		let webView = app.webViews["authWebView"]
		
		XCTAssertTrue(webView.waitForExistence(timeout: 5))

		let loginTextField = webView.descendants(matching: .textField).element
		XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
		
		loginTextField.tap()
		sleep(5)
		loginTextField.typeText("Danya6846084@gmail.com")
		sleep(3)
		if app.toolbars.buttons["Done"].exists {app.toolbars.buttons["Done"].tap()}
		
		let passwordTextField = webView.descendants(matching: .secureTextField).element
		XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
		
		passwordTextField.tap()
		sleep(5)
		passwordTextField.typeText("3yyhN816HP6Y3fq")
		sleep(3)
		if app.toolbars.buttons["Done"].exists {app.toolbars.buttons["Done"].tap()}
		
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
		let element = app.tabBars.buttons.element(boundBy: 1)
		XCTAssertTrue(element.waitForExistence(timeout: 5))
		element.tap()
	   
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


