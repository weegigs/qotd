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

import WeeDux

enum QuoteMessage: ApplicationMessage {
  case categoriesLoading
  case categoriesLoadingFailed(error: QuoteServiceError)
  case categoriesLoaded(categories: [QuoteCategory])

  case quoteLoading(category: String)
  case quoteLoadingFailed(category: String, error: QuoteServiceError)
  case quoteLoaded(category: String, quote: Quote)
}

private let categoriesLoading = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case .categoriesLoading = message
  else { return }

  state = .loading
}

private let categoriesLoadingFailed = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .categoriesLoadingFailed(error) = message
  else { return }

  state = .failed(error.description)
}

private let categoriesLoaded = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .categoriesLoaded(categories) = message
  else { return }

  state = .available(categories.sorted { $0.id > $1.id })
}

private let quoteLoading = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoading(category) = message
  else { return }

  state[category] = .loading
}

private let quoteLoadingFailed = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoadingFailed(category, error) = message
  else { return }

  state[category] = .failed(error.description)
}

private let quoteLoaded = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoaded(category, quote) = message
  else { return }

  state[category] = .available(quote)
}

let quoteMessageHandler = ApplicationMessageHandler(
  reducer: categoriesLoading <> categoriesLoadingFailed <> categoriesLoaded
    <> quoteLoading <> quoteLoadingFailed <> quoteLoaded
)