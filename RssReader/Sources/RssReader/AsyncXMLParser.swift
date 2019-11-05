import Foundation

class AsyncXMLParser<ItemType: Parsable>: XMLParsingListenerDelegate {
  func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_ listener: ListenerType)
    where ListenerType.ItemType == ItemType {
    completed(listener.result)
  }

  let parser: XMLParser
  let listener = XMLParserListener<ItemType, AsyncXMLParser>()
  let completed: (Result<[ItemType], Error>) -> Void

  init?(contentOf url: URL, completed: @escaping ((Result<[ItemType], Error>) -> Void)) {
    guard let parser = XMLParser(contentsOf: url) else {
      return nil
    }
    self.completed = completed
    self.parser = parser
    self.parser.delegate = listener
    listener.delegate = self
    self.parser.parse()
  }
}
