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
public struct RssItemEnclosure {
  let url: URL
  let length: Int
}

extension RssItemEnclosure: ElementDecodable {
  public static func transform(
    fromContent _: String?,
    withAttributes attributes: [String: String]
  ) throws -> RssItemEnclosure {
    guard let length = attributes["length"].flatMap({
      Int($0)
    }) else {
      throw ContentDecodingError.invalidAttribute("length")
    }

    guard let url = attributes["url"].flatMap({
      URL(string: $0)
    }) else {
      throw ContentDecodingError.invalidAttribute("url")
    }

    return RssItemEnclosure(url: url, length: length)
  }
}
