//
//  PublishingXMLParser.swift
//  XMLReader
//
//  Created by Leo Dion on 11/6/19.
//

import Foundation
import Combine

@available(OSX 10.15, *)
public class PublishingXMLParser<ItemType: Parsable>: XMLParsingListenerDelegate, ItemCollectionBuilder {
  let doesFinish : Bool
  let subject : CurrentValueSubject<[ItemType], Error>
  var items = [ItemType]() {
    didSet {
      subject.send(self.items)
    }
  }
  public func send(_ item: ItemType) {
    self.items.append(item)
  }
  
  public func send(error: Error) {
    subject.send(completion: .failure(error))
  }
  
  public func finish() {
    subject.send(completion: .finished)
  }
  
  
  typealias ParserType = PublishingXMLParser<ItemType>
  typealias ListenerType = XMLParserListener<ItemType, ParserType, ParserType>


  public func parsingCompleted<ListenerType: XMLParsingListenerProtocol>(_: ListenerType)
    where ListenerType.ItemType == ItemType {
    //itemCollection.finish()
    //completed(itemCollection.result!)
      if self.doesFinish {
        self.finish()
      }
  }

  let url : URL
  let parser: XMLParser?
  var listener: ListenerType?

  public init(contentOf url: URL, autostart: Bool, doesFinish: Bool,  for _: ItemType.Type) {
    self.doesFinish = doesFinish
    self.url = url
    self.subject = CurrentValueSubject(self.items)
    if let parser = XMLParser(contentsOf: url) {
      self.parser = parser
      let listener = ListenerType(itemCollectionBuilder: self)
      self.listener = listener
      parser.delegate = listener
      listener.delegate = self
    } else {
      self.parser = nil
      self.listener = nil
    }
    if autostart {
      self.parse()
    }
    //self.completed = completed
  }
  
  public func parse () {
    guard let parser = self.parser else {
      self.send(error: XMLParserError.invalidContent(url))
      return
    }
    parser.parse()
  }
  
  public func publisher () -> AnyPublisher<[ItemType], Error> {
    return self.subject.eraseToAnyPublisher()
  }
}
