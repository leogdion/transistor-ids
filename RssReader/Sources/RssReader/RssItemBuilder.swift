import Foundation
class RssItemBuilder {
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
}
