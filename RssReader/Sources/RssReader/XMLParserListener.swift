import Foundation

class XMLParserListener<ItemType, BuilderType: Builder, DelegateType: XMLParsingListenerDelegate>: NSObject, XMLParserDelegate, XMLParsingListenerProtocol where BuilderType.ItemType == ItemType, DelegateType.ItemType == ItemType, ItemType.BuilderType == BuilderType {
  var currentItem: BuilderType?
  var items = [ItemType]()
  var error: Error?
  var textContent: String?
  var attributes: [String: String]?
  var currentPath: [String]? {
    didSet {
      debugPrint(self.currentPath ?? "")
    }
  }

  weak var delegate: DelegateType?
  var result: Result<[ItemType], Error> {
    if let error = error {
      return .failure(error)
    } else {
      return .success(items)
    }
  }

  func parserDidStartDocument(_: XMLParser) {
    currentPath = [String]()
  }

  func parserDidEndDocument(_: XMLParser) {
    currentPath = nil
    delegate?.parsingCompleted(self)
  }

  func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
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
        error = RssParserError.invalidEndTag(elementName)
        return
      }
      do {
        items.append(try builder.item())
      } catch {
        self.error = error
        return
      }
    } else if let currentPath = self.currentPath, let builder = self.currentItem, let attributes = self.attributes {
      if currentPath.starts(with: ItemType.path), currentPath.count == 4 {
        do {
          try builder.set(key: elementName, fromContent: textContent, withAttributes: attributes)

        } catch {
          self.error = RssParserError.invalidContentForElementName(elementName, error)
        }
      }
    }

    _ = currentPath?.popLast()
    attributes = nil
    textContent = nil
  }
}
