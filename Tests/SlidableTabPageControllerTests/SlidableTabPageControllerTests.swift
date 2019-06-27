import XCTest
@testable import SlidableTabPageController

final class SlidableTabPageControllerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let vc = SlidableTabPageControllerFactory.make(pages: [])
        XCTAssertEqual(vc.currentPageIndex, 0)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
