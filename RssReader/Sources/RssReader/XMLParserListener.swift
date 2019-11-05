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

class XMLParserListener
<ItemType: Parsable, DelegateType: XMLParsingListenerDelegate, ItemCollectionType: ItemCollectionBuilder>:
  NSObject, XMLParserDelegate, XMLParsingListenerProtocol
  where DelegateType.ItemType == ItemType, ItemCollectionType.ItemType == ItemType {
  typealias BuilderType = ItemType.BuilderType
  var currentItem: BuilderType?
  var itemCollectionBuilder: ItemCollectionType
  var textContent: String?
  var attributes: [String: String]?
  var currentPath: [String]?

  weak var delegate: DelegateType?

  init(itemCollectionBuilder: ItemCollectionType) {
    self.itemCollectionBuilder = itemCollectionBuilder
  }

  func parserDidStartDocument(_: XMLParser) {
    currentPath = [String]()
  }

  func parserDidEndDocument(_: XMLParser) {
    currentPath = nil
    delegate?.parsingCompleted(self)
  }

  func parser(
    _: XMLParser,
    didStartElement elementName: String,
    namespaceURI _: String?,
    qualifiedName _: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    print(elementName)
    currentPath?.append(elementName)
    attributes = attributeDict
    if currentPath == ItemType.path {
      currentItem = ItemType.builder()
      return
    }
  }

  func parser(_: XMLParser, foundCharacters string: String) {
    textContent = string
  }

  func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
    if elementName == ItemType.path.last, currentPath == ItemType.path {
      // self.items = self.currentItem.item
      guard let builder = self.currentItem else {
        itemCollectionBuilder.send(error: RssParserError.invalidEndTag(elementName))
        return
      }
      do {
        itemCollectionBuilder.send(try builder.item())
      } catch {
        itemCollectionBuilder.send(error: error)
        return
      }
    } else if let currentPath = self.currentPath, let builder = self.currentItem, let attributes = self.attributes {
      if currentPath.starts(with: ItemType.path), currentPath.count == 4 {
        do {
          try builder.set(key: elementName, fromContent: textContent, withAttributes: attributes)

        } catch {
          itemCollectionBuilder.send(error: RssParserError.invalidContentForElementName(elementName, error))
        }
      }
    }

    _ = currentPath?.popLast()
    attributes = nil
    textContent = nil
  }
}
