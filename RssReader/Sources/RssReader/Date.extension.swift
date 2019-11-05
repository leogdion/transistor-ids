import Foundation
extension Date: SimpleContentDecodable {
  static func transform(fromContent content: String) -> Date? {
    return RssDateFormatter.formatter.date(from: content)
  }
}
