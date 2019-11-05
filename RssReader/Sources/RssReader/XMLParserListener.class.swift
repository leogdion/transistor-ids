import Foundation
class XMLParserListener : NSObject, XMLParserDelegate, XMLParsingListener {
  var currentItem : RssItemBuilder?
  var items = [RssItem]()
  var error : Error?
  var textContent : String?
  var attributes : [String:String]?
  var currentPath : [String]? {
    didSet {
      debugPrint(self.currentPath ?? "")
    }
  }
  weak var delegate : XMLParsingListenerDelegate?
  var result : Result<[RssItem], Error>{
    if let error = error {
      return .failure(error)
    } else {
      return .success(self.items)
    }
  }
  func parserDidStartDocument(_ parser: XMLParser) {
    self.currentPath = [String]()
  }
  
  func parserDidEndDocument(_ parser: XMLParser) {
    self.currentPath = nil
    self.delegate?.parsingCompleted(self)
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    print(elementName)
    self.currentPath?.append(elementName)
    self.attributes = attributeDict
    if self.currentPath == ["rss","channel", "item"] {
      self.currentItem = RssItemBuilder()
      return
    }
    
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    self.textContent = string

  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "item" && self.currentPath == ["rss","channel", "item"] {
      //self.items = self.currentItem.item
      guard let builder = self.currentItem else {
        error = RssParserError.invalidEndTag(elementName)
        return
      }
      do {
        self.items.append(try builder.item())
      } catch let error {
        self.error = error
        return
      }
    } else if let currentPath = self.currentPath, let builder = self.currentItem, let attributes = self.attributes {
      if currentPath.starts(with: ["rss","channel", "item"]) && currentPath.count == 4 {
        do {
          
          if elementName == "title" {builder.title = try transform(fromContent: self.textContent, withAttributes: attributes)}
          if elementName == "itunes:episode" {builder.episode = try transform(fromContent: self.textContent, withAttributes: attributes)}
          if elementName == "guid" {builder.guid = try transform(fromContent: self.textContent, withAttributes: attributes)}
          if elementName == "link" {builder.link = try transform(fromContent: self.textContent, withAttributes: attributes)}
          if elementName == "description" {builder.description = try transform(fromContent: self.textContent, withAttributes: attributes)}
          if elementName == "pubDate" {builder.pubDate = try transform(fromContent: self.textContent, withAttributes: attributes)}
          if elementName == "enclosure" {builder.enclosure = try transform(fromContent: self.textContent, withAttributes: attributes)}
        } catch let error {
          self.error = RssParserError.invalidContentForElementName(elementName, error)
        }
      }
    }
    
    _ = self.currentPath?.popLast()
    self.attributes = nil
    self.textContent = nil
  }
  
  func transform<Result>(fromContent content: String?, withAttributes attributes: [String:String]) throws -> Result where Result:ElementDecodable {
    return try Result.transform(fromContent: content, withAttributes: attributes)
  }
}
