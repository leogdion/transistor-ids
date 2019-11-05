//
//  File.swift
//
//
//  Created by Leo Dion on 11/4/19.
//

import Foundation

struct RssDateFormatter {
  static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
    return formatter
  }()

  private init() {}
}
