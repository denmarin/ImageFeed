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
}
