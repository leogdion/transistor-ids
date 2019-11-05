protocol XMLParsingListenerDelegate: AnyObject {
  associatedtype ItemType
  func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_ listener: ListenerType)
    where ListenerType.ItemType == ItemType
}
