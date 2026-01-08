import Foundation

enum RuntimeEnvironment {
    static var isUnitTesting: Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
        return NSClassFromString("XCTestCase") != nil
    }

    static var isUITesting: Bool {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments
        return env["UITESTING"] != nil || args.contains("UITESTING")
    }

    /// Optional limit for the number of pages to load during UI tests.
    /// Read from launch environment variable `UITESTS_MAX_PAGES`.
    static var uiTestsMaxPages: Int? {
        if let value = ProcessInfo.processInfo.environment["UITESTS_MAX_PAGES"],
           let intValue = Int(value) {
            return intValue
        }
        return nil
    }
}
