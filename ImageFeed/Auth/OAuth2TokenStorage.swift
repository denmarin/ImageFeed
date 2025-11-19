import Foundation
import SwiftKeychainWrapper

actor OAuth2TokenStorage {
	static let shared = OAuth2TokenStorage()
	private let kw = KeychainWrapper.standard
	private let tokenKey = "OAuthBearerToken"
	
	private init() {}
	
	var token: String? {
		get { get() }
		set { set(newValue) }
	}
	
	func get() -> String? {
		return kw.string(forKey: tokenKey)
	}
	
	func set(_ value: String?) {
		if let value {
			kw.set(value, forKey: tokenKey)
		} else {
			kw.removeObject(forKey: tokenKey)
		}
	}
}
