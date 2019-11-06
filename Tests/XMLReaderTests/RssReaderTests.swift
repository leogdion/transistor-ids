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

import Combine
import XCTest
@testable import XMLReader

final class XMLReaderTests: XCTestCase {
  let url = URL(string: "https://feeds.transistor.fm/empowerapps-show")!
  func testAsyncXMLParser() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let currentExp = expectation(description: "parsing finished")
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
    if #available(OSX 10.15, *) {
      let exp = expectation(description: "items received")
      var items: [RssItem]?
      let cancellable = XMLPublishingParser<RssItem>(contentsOf: url)!.catch { _ in
        Empty<[RssItem], Never>()
      }.sink { _items in
        items = _items
        exp.fulfill()
      }

//      let cancellable = publisher.sink(receiveCompletion: { completion in
//        switch completion {
//        case let .failure(error):
//          XCTFail(error.localizedDescription)
//        default: break
//        }
//        exp.fulfill()
//      }) { value in
//        debugPrint(value)
//        count += 1
//      }
      waitForExpectations(timeout: 10000) { error in
        XCTAssertNil(error)

        guard let items = items else {
          XCTFail()
          return
        }
        XCTAssertGreaterThanOrEqual(items.count, 20)
        XCTAssertLessThan(items.count, 100)
      }
    } else {
      // Fallback on earlier versions
    }
  }

//  func testPublisherCollection() {
//    if #available(OSX 10.15, *) {
//      let exp = expectation(description: "items received")
//      var count = 0
//      let parser = XMLPublishingParser<RssItem>(contentsOf: url)!
//      let publisher = parser.publisher().collect()
//      var items: [RssItem]?
//
//      let cancellable = publisher.sink(receiveCompletion: { completion in
//        switch completion {
//        case let .failure(error):
//          XCTFail(error.localizedDescription)
//        default: break
//        }
//        exp.fulfill()
//      }) { actualItems in
//        items = actualItems
//      }
//      waitForExpectations(timeout: 10000) { error in
//        XCTAssertNil(error)
//
//        XCTAssertGreaterThanOrEqual(items!.count, 20)
//        XCTAssertLessThan(items!.count, 100)
//      }
//    } else {
//      // Fallback on earlier versions
//    }
//  }

  static var allTests = [
    ("testAsyncXMLParser", testAsyncXMLParser),
    ("testPublisher", testPublisher),
    // ("testPublisherCollection", testPublisherCollection)
  ]
}
