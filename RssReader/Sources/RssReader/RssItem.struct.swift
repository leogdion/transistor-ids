import Foundation
struct RssItem  {
  let title : String
  let episode: Int
  let guid: UUID
  let link : URL
  let description : String
  let pubDate : Date
  let enclosure : RssItemEnclosure
}
