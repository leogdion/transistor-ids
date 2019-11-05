// MIT License
//
// Copyright (c) 2019 BrightDigit, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

  func testPublisher() {}

  static var allTests = [
    ("testAsyncXMLParser", testAsyncXMLParser),
    ("testPublisher", testPublisher)
  ]
}
