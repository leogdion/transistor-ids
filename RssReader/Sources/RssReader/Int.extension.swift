import Foundation
extension Int: SimpleContentDecodable {
  static func transform(fromContent content: String) -> Int? {
    return Int(content)
  }
}
