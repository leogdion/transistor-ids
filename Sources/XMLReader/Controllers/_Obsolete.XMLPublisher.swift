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
public class XMLPublisher<ItemType>: ItemCollectionBuilder {
  let subject: CurrentValueSubject<[ItemType], Error>
  var items: [ItemType] {
    didSet {
      debugPrint("item count sent", items.count)
      subject.send(items)
    }
  }

  init() {
    let items = [ItemType]()
    subject = CurrentValueSubject(items)
    self.items = items
  }

  public func send(_ item: ItemType) {
    debugPrint("recieved item")
    items.append(item)
  }

  public func send(error: Error) {
    subject.send(completion: .failure(error))
  }

  public func finish() {
    subject.send(completion: .finished)
  }
}

@available(OSX 10.15, *)
public class XMLPublishingParser<ItemType: Parsable>: XMLParsingListenerDelegate, Publisher {
  public func receive<S>(subscriber: S) where S: Subscriber, XMLPublishingParser.Failure == S.Failure, XMLPublishingParser.Output == S.Input {
    publishingSubject.subject.receive(subscriber: subscriber)
    // self.publisher.receive(subscriber: subscriber)
  }

  public typealias Output = [ItemType]

  public typealias Failure = Error

  typealias XMLPublisherType = XMLPublisher<ItemType>
  typealias ParserType = XMLPublishingParser<ItemType>
  typealias ListenerType = XMLParserListener<ItemType, ParserType, XMLPublisherType>
  var publishingSubject: XMLPublisherType {
    return itemsListener.0
  }

  public func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_: ListenerType)
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

  public init?(contentsOf url: URL) {
    guard let parser = XMLParser(contentsOf: url) else {
      return nil
    }
    self.parser = parser
    parser.delegate = listener
    listener.delegate = self
    defer {
      self.parser.parse()
    }
//    let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: url)
//    dataTaskPublisher.combineLatest(self.publishingSubject.subject).map
//    let itemsPublisher = dataTaskPublisher.mapError({
//      return $0 as Error
//    }).flatMap { (dataResult) -> AnyPublisher<[ItemType], Error> in
//      let parser = XMLParser(data: dataResult.data)
//      parser.delegate = self.listener
//      self.parser = parser
//      self.listener.delegate = self
//
//      defer{
//        parser.parse()
//      }
//
//      return self.publishingSubject.subject.eraseToAnyPublisher()
//    }.map({ (items) -> [ItemType] in
//      debugPrint("recieved items:", items.count)
//      debugPrint(items)
//      return items
//    }).eraseToAnyPublisher()
//    self.publisher = itemsPublisher
//
  }
}
