import Foundation
extension Date : SimpleContentDecodable {
  static func transform(fromContent content: String) -> Date? {
    return dateFormatter.date(from: content)
  }
}
