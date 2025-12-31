//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 31.12.25.
//

import Foundation

public protocol WebViewPresenterProtocol {
	func viewDidLoad()
	func didUpdateProgressValue(_ newValue: Double)
	func code(from url: URL) -> String?
	var view: WebViewViewControllerProtocol? { get set }
}

enum WebViewConstants {
	static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewPresenter: WebViewPresenterProtocol {
	weak var view: WebViewViewControllerProtocol?
	
	func viewDidLoad() {
		guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
			print("Failed to create URLComponents from auth URL string")
			return
		}
		
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: Constants.accessKey),
			URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "scope", value: Constants.accessScope)
		]
		
		guard let url = urlComponents.url else {
			print("urlComponents error")
			return
		}
		
		let request = URLRequest(url: url)
		view?.load(request: request)
	}
	
	func code(from url: URL) -> String? {
		if let urlComponents = URLComponents(string: url.absoluteString),
		   urlComponents.path == "/oauth/authorize/native",
		   let items = urlComponents.queryItems,
		   let codeItem = items.first(where: { $0.name == "code" })
		{
			return codeItem.value
		} else {
			return nil
		}
	} 
	
	func didUpdateProgressValue(_ newValue: Double) {
		let newProgressValue = Float(newValue)
		view?.setProgressValue(newProgressValue)
		
		let shouldHideProgress = shouldHideProgress(for: newProgressValue)
		view?.setProgressHidden(shouldHideProgress)
	}
		
	func shouldHideProgress(for value: Float) -> Bool {
		abs(value - 1.0) <= 0.0001
	}
	
} 
