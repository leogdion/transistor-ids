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
import Foundation

@available(OSX 10.15, *)
class XMLPublisher<ItemType>: ItemCollectionBuilder {
  let subject = PassthroughSubject<ItemType, Error>()

  func send(_ item: ItemType) {
    subject.send(item)
  }

  func send(error: Error) {
    subject.send(completion: .failure(error))
  }

  func finish() {
    subject.send(completion: .finished)
  }
}

@available(OSX 10.15, *)
class XMLPublishingParser<ItemType: Parsable>: XMLParsingListenerDelegate {
  typealias XMLPublisherType = XMLPublisher<ItemType>
  typealias ParserType = XMLPublishingParser<ItemType>
  typealias ListenerType = XMLParserListener<ItemType, ParserType, XMLPublisherType>
  var publishingSubject: XMLPublisherType {
    return itemsListener.0
  }

  func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_: ListenerType)
    where ListenerType.ItemType == ItemType {
    publishingSubject.finish()
  }

  let parser: XMLParser
  var listener: ListenerType {
    return itemsListener.1
  }

  let itemsListener = { () -> (XMLPublisherType, ListenerType) in
    let xmlpublisher = XMLPublisherType()
    let listener = ListenerType(itemCollectionBuilder: xmlpublisher)
    return (xmlpublisher, listener)
  }()

  init?(contentsOf url: URL) {
    guard let parser = XMLParser(contentsOf: url) else {
      return nil
    }
    // self.completed = completed
    self.parser = parser
    self.parser.delegate = listener
    listener.delegate = self
    // self.parser.parse()
  }

  func begin() {
    parser.parse()
  }
}

@available(OSX 10.15, *)
extension XMLPublishingParser {
  func publisher() -> AnyPublisher<ItemType, Error> {
    return publishingSubject.subject.eraseToAnyPublisher()
  }
}
