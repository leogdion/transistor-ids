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

import Foundation

class AsyncXMLParser<ItemType: Parsable>: XMLParsingListenerDelegate {
  typealias ItemCollectionType = ItemCollection<ItemType>
  typealias ParserType = AsyncXMLParser<ItemType>
  typealias ListenerType = XMLParserListener<ItemType, ParserType, ItemCollectionType>
  var itemCollection: ItemCollectionType {
    return itemsListener.0
  }

  func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_: ListenerType)
    where ListenerType.ItemType == ItemType {
    completed(itemCollection.result)
  }

  let parser: XMLParser
  var listener: ListenerType {
    return itemsListener.1
  }

  let itemsListener = { () -> (ItemCollectionType, ListenerType) in
    let itemCollection = ItemCollectionType()
    let listener = ListenerType(itemCollectionBuilder: itemCollection)
    return (itemCollection, listener)
  }()

  let completed: (Result<[ItemType], Error>) -> Void

  init?(contentOf url: URL, completed: @escaping ((Result<[ItemType], Error>) -> Void)) {
    guard let parser = XMLParser(contentsOf: url) else {
      return nil
    }
    self.completed = completed
    self.parser = parser
    self.parser.delegate = listener
    listener.delegate = self
    self.parser.parse()
  }
}
