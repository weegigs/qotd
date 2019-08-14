// MIT License
//
// Copyright (c) 2019 Kevin O'Neill
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Combine
import SwifTEA

typealias QuoteCommand = Command<QuoteEnvironment, QuoteMessage>

enum QuoteCommands {
  static let refreshQOD = { (category: String) -> QuoteCommand in
    QuoteCommand { environment, publish in
      let task = environment.quotes.qod(category: category) { result in
        switch result {
        case let .failure(error):
          publish(QuoteMessage.quoteLoadingFailed(category: category, error: error))
        case let .success(quote):
          publish(QuoteMessage.quoteLoaded(category: category, quote: quote))
        }
      }

      publish(QuoteMessage.quoteLoading(category: category, task: task))
    }
  }
}
