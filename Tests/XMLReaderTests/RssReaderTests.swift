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
  let podcastURL = URL(string: "https://feeds.transistor.fm/empowerapps-show")!
  let rssURL = URL(string: "https://lorem-rss.herokuapp.com/feed?unit=second")!
  func testAsyncXMLParser() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let currentExp = expectation(description: "parsing finished")
    var result: Result<[RssItem], Error>?
    let parser = AsyncXMLParser(contentOf: rssURL, for: RssItem.self) { actualResult in
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

      XCTAssertEqual(items.count, 10)
    }
  }

  func testRssPublisher() {
    if #available(OSX 10.15, *) {
      var count = 0
      let exp = expectation(description: "items received")
      let parser = PublishingXMLParser(contentOf: rssURL, autostart: false, doesFinish: true, for: RssItem.self)

      let publisher = parser.publisher()

      let cancellable = publisher.sink(receiveCompletion: { completion in
        switch completion {
        case let .failure(error):
          XCTFail(error.localizedDescription)
        default: break
        }
        exp.fulfill()
      }, receiveValue: { value in
        debugPrint(value)
        count += 1
      })
      parser.parse()
      waitForExpectations(timeout: 10000) { error in
        XCTAssertNil(error)

        XCTAssertEqual(count, 11)
      }
    } else {
      // Fallback on earlier versions
    }
  }

  func testBadPodcastPublisher() {
    if #available(OSX 10.15, *) {
      var count = 0
      let exp = expectation(description: "items received")
      let parser = PublishingXMLParser(contentOf: rssURL, autostart: false, doesFinish: true, for: PodcastRssItem.self)

      let publisher = parser.publisher()

      let cancellable = publisher.sink(receiveCompletion: { completion in
        switch completion {
        case let .failure(error):
          if case let .missingFieldName(field) = error as? XMLParserError {
            XCTAssertEqual(field, "episode")
            exp.fulfill()
          }

        default: break
        }
      }, receiveValue: { value in
        debugPrint(value)
        count += 1
      })
      parser.parse()
      waitForExpectations(timeout: 10000) { error in
        XCTAssertNil(error)
      }
    } else {
      // Fallback on earlier versions
    }
  }

  func testPodcastPublisher() {
    if #available(OSX 10.15, *) {
      var count = 0
      let exp = expectation(description: "items received")
      let parser = PublishingXMLParser(
        contentOf: podcastURL,
        autostart: false,
        doesFinish: true,
        for: PodcastRssItem.self
      )

      let publisher = parser.publisher()

      let cancellable = publisher.sink(receiveCompletion: { completion in
        switch completion {
        case let .failure(error):
          XCTFail(error.localizedDescription)
        default: break
        }
        exp.fulfill()
      }, receiveValue: { value in
        debugPrint(value)
        count += 1
      })
      parser.parse()
      waitForExpectations(timeout: 10000) { error in
        XCTAssertNil(error)

        XCTAssertGreaterThanOrEqual(count, 20)
        XCTAssertLessThan(count, 100)
      }
    } else {
      // Fallback on earlier versions
    }
  }

  func testErrorPublisher() {
    if #available(OSX 10.15, *) {
      let exp = expectation(description: "items failed")
      let badUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

      FileManager.default.createFile(atPath: badUrl.path, contents: nil, attributes: nil)
      let parser = PublishingXMLParser(contentOf: badUrl, autostart: false, doesFinish: true, for: RssItem.self)

      let publisher = parser.publisher()

      let cancellable = publisher.sink(receiveCompletion: { completion in
        switch completion {
        case let .failure(error):
          exp.fulfill()
        default: break
        }

      }, receiveValue: { _ in

      })
      parser.parse()
      waitForExpectations(timeout: 10000) { error in
        XCTAssertNil(error)
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
    ("testRssPublisher", testRssPublisher),
    ("testPodcastPublisher", testPodcastPublisher),
    ("testErrorPublisher", testErrorPublisher),
    // ("testPublisherCollection", testPublisherCollection)
  ]
}
