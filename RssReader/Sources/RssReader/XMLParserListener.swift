import Foundation
class XMLParserListener: NSObject, XMLParserDelegate, XMLParsingListener {
  var currentItem: RssItemBuilder?
  var items = [RssItem]()
  var error: Error?
  var textContent: String?
  var attributes: [String: String]?
  var currentPath: [String]? {
    didSet {
      debugPrint(self.currentPath ?? "")
    }
  }

  weak var delegate: XMLParsingListenerDelegate?
  var result: Result<[RssItem], Error> {
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
    if currentPath == ["rss", "channel", "item"] {
      currentItem = RssItemBuilder()
      return
    }
  }

  func parser(_: XMLParser, foundCharacters string: String) {
    textContent = string
  }

  func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
    if elementName == "item", currentPath == ["rss", "channel", "item"] {
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
      if currentPath.starts(with: ["rss", "channel", "item"]), currentPath.count == 4 {
        do {
          if elementName == "title" { builder.title = try transform(fromContent: textContent, withAttributes: attributes) }
          if elementName == "itunes:episode" { builder.episode = try transform(fromContent: textContent, withAttributes: attributes) }
          if elementName == "guid" { builder.guid = try transform(fromContent: textContent, withAttributes: attributes) }
          if elementName == "link" { builder.link = try transform(fromContent: textContent, withAttributes: attributes) }
          if elementName == "description" { builder.description = try transform(fromContent: textContent, withAttributes: attributes) }
          if elementName == "pubDate" { builder.pubDate = try transform(fromContent: textContent, withAttributes: attributes) }
          if elementName == "enclosure" { builder.enclosure = try transform(fromContent: textContent, withAttributes: attributes) }
        } catch {
          self.error = RssParserError.invalidContentForElementName(elementName, error)
        }
      }
    }

    _ = currentPath?.popLast()
    attributes = nil
    textContent = nil
  }

  func transform<Result>(fromContent content: String?, withAttributes attributes: [String: String]) throws -> Result where Result: ElementDecodable {
    return try Result.transform(fromContent: content, withAttributes: attributes)
  }
}
