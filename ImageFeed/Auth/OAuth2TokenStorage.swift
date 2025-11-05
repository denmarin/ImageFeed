import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuthBearerToken"
    private let defaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }

    var token: String? {
        get { get() }
        set { set(newValue) }
    }

    func set(_ value: String?) {
        if let value = value {
            defaults.set(value, forKey: tokenKey)
        } else {
            defaults.removeObject(forKey: tokenKey)
        }
    }

    func get() -> String? {
        return defaults.string(forKey: tokenKey)
    }
}
