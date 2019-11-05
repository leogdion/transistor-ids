import Foundation
struct RssItemEnclosure {
  let url: URL
  let length: Int
}

extension RssItemEnclosure: ElementDecodable {
  static func transform(fromContent _: String?, withAttributes attributes: [String: String]) throws -> RssItemEnclosure {
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
