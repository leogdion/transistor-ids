protocol XMLParsingListenerProtocol {
  associatedtype ItemType
  var result: Result<[ItemType], Error> { get }
}
