import XCTest
@testable import SwiftWordNumber

final class SwiftWordNumberTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftWordNumber().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
