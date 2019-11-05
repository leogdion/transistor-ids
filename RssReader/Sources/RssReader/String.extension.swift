extension String: ElementDecodable {
  static func transform(fromContent content: String?, withAttributes _: [String: String]) throws -> String {
    guard let content = content else {
      throw ContentDecodingError.missingValue
    }
    return content
  }
}
