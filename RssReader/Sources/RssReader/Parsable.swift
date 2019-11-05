//
//  File.swift
//
//
//  Created by Leo Dion on 11/5/19.
//

import Foundation
protocol Parsable {
  associatedtype BuilderType: Builder where BuilderType.ItemType == Self
  static func builder() -> BuilderType
  static var path: [String] { get }
}
