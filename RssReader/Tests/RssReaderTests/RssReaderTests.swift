@testable import RssReader
import XCTest

final class RssReaderTests: XCTestCase {
  func testAsyncXMLParser() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let currentExp = expectation(description: "parsing finished")
    let url = URL(string: "https://feeds.transistor.fm/empowerapps-show")!
    var result: Result<[RssItem], Error>?
    let parser = AsyncXMLParser<RssItem>(contentOf: url) { actualResult in
      result = actualResult
      currentExp.fulfill()
    }
    XCTAssertNotNil(parser)
    waitForExpectations(timeout: 1000) { error in
      XCTAssertNil(error)
      let items: [RssItem]
      do {
        let actualResult = try XCTUnwrap(result)
        items = try actualResult.get()
      } catch {
        XCTAssertNil(error)
        return
      }

      XCTAssertGreaterThanOrEqual(items.count, 20)
      XCTAssertLessThan(items.count, 100)
    }
  }

  func testPublisher() {
  }

  static var allTests = [
    ("testAsyncXMLParser", testAsyncXMLParser),
    ("testPublisher", testPublisher)
  ]
}
