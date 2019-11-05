import Cocoa


protocol XMLParsingListenerDelegate : AnyObject {
  func parsingCompleted(_ listener: XMLParsingListener)
}
class AsyncXMLParser : XMLParsingListenerDelegate {
  func parsingCompleted(_ listener: XMLParsingListener) {
    completed(listener.result)
  }
  
  let parser : XMLParser
  let listener = XMLParserListener()
  let completed : ((Result<[RssItem], Error>) -> Void)
  
  init?(contentOf url: URL, completed: @escaping ((Result<[RssItem], Error>) -> Void)) {
    guard let parser = XMLParser(contentsOf: url) else {
      return nil
    }
    self.completed = completed
    self.parser = parser
    self.parser.delegate = self.listener
    self.listener.delegate = self
    self.parser.parse()
  }
  
}

enum RssParserError : Error {
  case missingFieldName(String)
  case invalidEndTag(String)
  case invalidContentForElementName(String, Error)
}

enum ContentDecodingError: Error {
  case missingValue
  case invalidAttribute(String)
  case invalidValue
}


let dateFormatter : DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
  return formatter
}()
let rss_feed = "https://feeds.transistor.fm/empowerapps-show"
let url = URL(string: rss_feed)!

protocol ElementDecodable {
  static func transform(fromContent content: String?, withAttributes attributes: [String:String]) throws -> Self
}

extension String :  ElementDecodable {
  static func transform(fromContent content: String?, withAttributes attributes: [String : String]) throws -> String {
    guard let content = content else {
      throw ContentDecodingError.missingValue
    }
    return content
  }
}
struct RssItemEnclosure {
  let url : URL
  let length : Int
}

extension RssItemEnclosure : ElementDecodable {
  static func transform(fromContent content: String?, withAttributes attributes: [String : String]) throws -> RssItemEnclosure {
    guard let length = attributes["length"].flatMap({
      Int($0)
    }) else {
      throw ContentDecodingError.invalidAttribute("length")
    }
    
    guard let url = attributes["url"].flatMap({
      URL(string: $0)
    }) else {
      throw ContentDecodingError.invalidAttribute("url")
    }
    
    return RssItemEnclosure(url: url, length: length)
  }
}

protocol SimpleContentDecodable : ElementDecodable{
  static func transform(fromContent content: String) -> Self?
}

extension SimpleContentDecodable {
  static func transform(fromContent content: String?, withAttributes attributes: [String : String]) throws -> Self {
    guard let result = content.flatMap({
      self.transform(fromContent: $0)
    }) else {
      throw ContentDecodingError.invalidValue
    }
    return result
  }
}
extension Int : SimpleContentDecodable {
  static func transform(fromContent content: String) -> Int? {
    return Int(content)
  }
}

extension UUID : SimpleContentDecodable {
  static func transform(fromContent content: String) -> UUID? {
    UUID(uuidString: content)
  }
}

extension Date : SimpleContentDecodable {
  static func transform(fromContent content: String) -> Date? {
    return dateFormatter.date(from: content)
  }
}

extension URL : SimpleContentDecodable {
  static func transform(fromContent content: String) -> URL? {
    return URL(string: content)
  }
}
struct RssItem  {
  let title : String
  let episode: Int
  let guid: UUID
  let link : URL
  let description : String
  let pubDate : Date
  let enclosure : RssItemEnclosure
}

class RssItemBuilder {
  var title : String? = nil
  var episode: Int? = nil
  var guid: UUID? = nil
  var link : URL? = nil
  var description : String? = nil
  var pubDate : Date? = nil
  var enclosure : RssItemEnclosure? = nil
  
  func item () throws -> RssItem {
    guard let title = title else {
      throw RssParserError.missingFieldName("title")
    }
      guard let episode = episode else {
        throw RssParserError.missingFieldName("episode")
    }
        guard let guid = guid else {
          throw RssParserError.missingFieldName("guid")
    }
          guard let link = link else {
            throw RssParserError.missingFieldName("transistorId")
    }
            guard let description = description else {
              throw RssParserError.missingFieldName("description")
    }
              guard let pubDate = pubDate else {
                throw RssParserError.missingFieldName("pubDate")
    }
                guard let enclosure = enclosure else {
                  throw RssParserError.missingFieldName("enclosure")
    }
    return RssItem(title: title, episode: episode, guid: guid, link: link, description: description, pubDate: pubDate, enclosure: enclosure)
  }
}

protocol XMLParsingListener {
  var result : Result<[RssItem], Error> { get }
}
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

