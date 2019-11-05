
protocol SimpleContentDecodable : ElementDecodable{
  static func transform(fromContent content: String) -> Self?
}
