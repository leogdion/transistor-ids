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


@available(OSX 10.15, *)
extension PassthroughSubject {
  func send(_ result : Result<Output, Failure>) {
    switch result {
    case .success(let output):
      self.send(output)
      self.send(completion: .finished)
    case .failure(let error):
      self.send(completion: .failure(error))
    }
  }
}
if #available(OSX 10.15, *) {
  let url = URL(string: "https://feeds.transistor.fm/empowerapps-show")!
  let subject = PassthroughSubject<[RssItem], Error>()
  let cancellable = subject.sink(receiveCompletion: {
    print($0)
    exit(0)
  }) {
    print($0)
  }
  let parser = AsyncXMLParser(contentOf: url, for: RssItem.self) { (result) in
    print("result")
    subject.send(result)
  }
  
  RunLoop.current.run()
} else {
  // Fallback on earlier versions
}
