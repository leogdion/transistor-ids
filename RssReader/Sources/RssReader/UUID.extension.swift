import Foundation
extension UUID: SimpleContentDecodable {
  static func transform(fromContent content: String) -> UUID? {
    UUID(uuidString: content)
  }
}
