import Foundation

class AsyncXMLParser<ItemType, BuilderType: Builder>: XMLParsingListenerDelegate where BuilderType.ItemType == ItemType, ItemType.BuilderType == BuilderType {
  func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_ listener: ListenerType) where ListenerType.ItemType == ItemType {
    completed(listener.result)
  }

  let parser: XMLParser
  let listener = XMLParserListener<ItemType, BuilderType, AsyncXMLParser>()
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
