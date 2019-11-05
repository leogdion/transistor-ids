// MIT License
//
// Copyright (c) 2019 BrightDigit, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
protocol SimpleContentDecodable: ElementDecodable {
  static func transform(fromContent content: String) -> Self?
}

extension SimpleContentDecodable {
  static func transform(fromContent content: String?, withAttributes _: [String: String]) throws -> Self {
    guard let result = content.flatMap({
      self.transform(fromContent: $0)
    }) else {
      throw ContentDecodingError.invalidValue
    }
    return result
  }
}

extension Int: SimpleContentDecodable {
  static func transform(fromContent content: String) -> Int? {
    return Int(content)
  }
}

extension UUID: SimpleContentDecodable {
  static func transform(fromContent content: String) -> UUID? {
    UUID(uuidString: content)
  }
}

extension URL: SimpleContentDecodable {
  static func transform(fromContent content: String) -> URL? {
    return URL(string: content)
  }
}
