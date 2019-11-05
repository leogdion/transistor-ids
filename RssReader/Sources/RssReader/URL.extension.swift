import Foundation
extension URL: SimpleContentDecodable {
  static func transform(fromContent content: String) -> URL? {
    return URL(string: content)
  }
}
