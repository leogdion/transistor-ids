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
