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

public class RssItemBuilder : AbstractRssItemBuilder, Builder {

  public typealias ItemType = RssItem
  
  public func item() throws -> RssItem {
      guard let title = title else {
        throw XMLParserError.missingFieldName("title")
      }
  //    guard let episode = episode else {
  //      throw XMLParserError.missingFieldName("episode")
  //    }
      guard let guid = guid else {
        throw XMLParserError.missingFieldName("guid")
      }
      guard let link = link else {
        throw XMLParserError.missingFieldName("link")
      }
      guard let description = description else {
        throw XMLParserError.missingFieldName("description")
      }
      guard let pubDate = pubDate else {
        throw XMLParserError.missingFieldName("pubDate")
      }
  //    guard let enclosure = enclosure else {
  //      throw XMLParserError.missingFieldName("enclosure")
  //    }
      return RssItem(
        title: title,
        episode: episode,
        guid: guid,
        link: link,
        description:
        description,
        pubDate: pubDate,
        enclosure: enclosure
      )
    }
}
