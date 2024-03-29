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

import Combine
import Foundation
import XMLReader

if #available(OSX 10.15, *) {
  let url = URL(string: "https://lorem-rss.herokuapp.com/feed?unit=second")!
  let publisher = Timer.publish(
    every: 1.0,
    tolerance:
    TimeInterval(1.0),
    on: .current,
    in: .default,
    options: nil
  ).autoconnect().flatMap { (date) -> AnyPublisher<[RssItem], Never> in
    let parser = PublishingXMLParser(contentOf: url, doesFinish: false, for: RssItem.self)
    print(date)
    let publisher = parser.publisher().catch { _ in
      Empty<[RssItem], Never>()
    }.eraseToAnyPublisher()
    return publisher
  }
  // let parser = DynamicXMLParser(contentOf: url, for: RssItem.self)

  let cancellable = publisher.sink(receiveCompletion: { completion in
    switch completion {
    case let .failure(error): exit(1)
    case .finished: exit(0)
    default: break
    }
  }, receiveValue: { value in
    debugPrint(value.count)
  })

  RunLoop.current.run()
} else {
  // Fallback on earlier versions
}
