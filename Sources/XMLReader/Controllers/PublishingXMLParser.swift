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
public class PublishingXMLParser<ItemType: Parsable>: XMLParsingListenerDelegate, ItemCollectionBuilder {
  let doesFinish: Bool
  let subject: CurrentValueSubject<[ItemType], Error>
  var items = [ItemType]() {
    didSet {
      subject.send(items)
    }
  }

  public func send(_ item: ItemType) {
    items.append(item)
  }

  public func send(error: Error) {
    subject.send(completion: .failure(error))
  }

  public func finish() {
    subject.send(completion: .finished)
  }

  typealias ParserType = PublishingXMLParser<ItemType>
  typealias ListenerType = XMLParserListener<ItemType, ParserType, ParserType>

  public func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_: ListenerType)
    where ListenerType.ItemType == ItemType {
    // itemCollection.finish()
    // completed(itemCollection.result!)
    if doesFinish {
      finish()
    }
  }

  let url: URL
  let parser: XMLParser?
  var listener: ListenerType?

  public init(contentOf url: URL, autostart: Bool = true, doesFinish: Bool = true, for _: ItemType.Type) {
    self.doesFinish = doesFinish
    self.url = url
    subject = CurrentValueSubject(items)
    if let parser = XMLParser(contentsOf: url) {
      self.parser = parser
      let listener = ListenerType(itemCollectionBuilder: self)
      self.listener = listener
      parser.delegate = listener
      listener.delegate = self
    } else {
      parser = nil
      listener = nil
    }
    if autostart {
      parse()
    }
    // self.completed = completed
  }

  public func parse() {
    guard let parser = self.parser else {
      send(error: XMLParserError.invalidContent(url))
      return
    }
    parser.parse()
    if let error = parser.parserError {
      send(error: error)
    }
  }

  public func publisher() -> AnyPublisher<[ItemType], Error> {
    return subject.eraseToAnyPublisher()
  }
}
