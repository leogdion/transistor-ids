import Foundation
class RssItemBuilder: Builder {
  func set(key: String, fromContent textContent: String?, withAttributes attributes: [String: String]) throws {
    if key == "title" { title = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
    if key == "itunes:episode" { episode = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
    if key == "guid" { guid = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
    if key == "link" { link = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
    if key == "description" { description = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
    if key == "pubDate" { pubDate = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
    if key == "enclosure" { enclosure = try RssItemBuilder.transform(fromContent: textContent, withAttributes: attributes) }
  }

  var title: String?
  var episode: Int?
  var guid: UUID?
  var link: URL?
  var description: String?
  var pubDate: Date?
  var enclosure: RssItemEnclosure?

  func item() throws -> RssItem {
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

  static func transform<Result>(fromContent content: String?, withAttributes attributes: [String: String]) throws -> Result where Result: ElementDecodable {
    return try Result.transform(fromContent: content, withAttributes: attributes)
  }
}
