//
//  Guid.swift
//  XMLReader
//
//  Created by Leo Dion on 11/7/19.
//

import Foundation

enum Guid {
  case uuid(UUID)
  case url(URL)
}

extension Guid : SimpleContentDecodable {
  static func transform(fromContent content: String) -> Guid? {
    if let uuid = UUID(uuidString: content) {
      return .uuid(uuid)
    } else if let url = URL(string: content) {
      return .url(url)
    }
    return nil
  }
}
