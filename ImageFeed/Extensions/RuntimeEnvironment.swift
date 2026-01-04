import Foundation

/// Centralized runtime environment checks to keep logic consistent across the app.
enum RuntimeEnvironment {
    /// True when running under XCTest (unit tests).
    static var isUnitTesting: Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
        return NSClassFromString("XCTestCase") != nil
    }

    /// True when running under UI testing (optional helper, based on conventional flags/arguments).
    static var isUITesting: Bool {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments
        return env["UITESTING"] != nil || args.contains("UITESTING")
    }
}
