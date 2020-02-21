import XCTest
@testable import DisQR

final class DisQRTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DisQR().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
