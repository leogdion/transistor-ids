import Foundation

class AsyncXMLParser : XMLParsingListenerDelegate {
  func parsingCompleted(_ listener: XMLParsingListener) {
    completed(listener.result)
  }
  
  let parser : XMLParser
  let listener = XMLParserListener()
  let completed : ((Result<[RssItem], Error>) -> Void)
  
  init?(contentOf url: URL, completed: @escaping ((Result<[RssItem], Error>) -> Void)) {
    guard let parser = XMLParser(contentsOf: url) else {
      return nil
    }
    self.completed = completed
    self.parser = parser
    self.parser.delegate = self.listener
    self.listener.delegate = self
    self.parser.parse()
  }
  
}
