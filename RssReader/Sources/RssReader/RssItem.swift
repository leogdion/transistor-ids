import Foundation
struct RssItem: Parsable {
  typealias BuilderType = RssItemBuilder

  static func builder() -> RssItemBuilder {
    return RssItemBuilder()
  }

  static let path = ["rss", "channel", "item"]

  let title: String
  let episode: Int
  let guid: UUID
  let link: URL
  let description: String
  let pubDate: Date
  let enclosure: RssItemEnclosure
}
