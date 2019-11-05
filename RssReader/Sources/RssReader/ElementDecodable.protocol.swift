protocol ElementDecodable {
  static func transform(fromContent content: String?, withAttributes attributes: [String: String]) throws -> Self
}
