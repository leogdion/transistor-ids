import Foundation
protocol SimpleContentDecodable: ElementDecodable {
  static func transform(fromContent content: String) -> Self?
}

extension SimpleContentDecodable {
  static func transform(fromContent content: String?, withAttributes _: [String: String]) throws -> Self {
    guard let result = content.flatMap({
      self.transform(fromContent: $0)
    }) else {
      throw ContentDecodingError.invalidValue
    }
    return result
  }
}

extension Int: SimpleContentDecodable {
  static func transform(fromContent content: String) -> Int? {
    return Int(content)
  }
}

extension UUID: SimpleContentDecodable {
  static func transform(fromContent content: String) -> UUID? {
    UUID(uuidString: content)
  }
}

extension URL: SimpleContentDecodable {
  static func transform(fromContent content: String) -> URL? {
    return URL(string: content)
  }
}
