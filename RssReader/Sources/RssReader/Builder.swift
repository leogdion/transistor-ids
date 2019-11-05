//
//  File.swift
//
//
//  Created by Leo Dion on 11/5/19.
//

import Foundation

protocol Builder {
  associatedtype ItemType: Parsable
  func item() throws -> ItemType
  func set(key: String, fromContent textContent: String?, withAttributes attributes: [String: String]) throws
}
