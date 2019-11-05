//
//  File.swift
//
//
//  Created by Leo Dion on 11/5/19.
//

import Foundation
protocol Parsable {
  associatedtype BuilderType: Builder
  static func builder() -> BuilderType
  static var path: [String] { get }
}
