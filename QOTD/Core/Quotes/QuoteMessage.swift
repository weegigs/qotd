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

enum QuoteMessage: ApplicationMessage {
  case categoriesLoading(task: Cancellable)
  case categoriesLoadingCancelled
  case categoriesLoadingFailed(error: QuoteServiceError)
  case categoriesLoaded(categories: [QuoteCategory])

  case quoteLoading(category: String, task: Cancellable)
  case quoteLoadingCancelled(category: String)
  case quoteLoadingFailed(category: String, error: QuoteServiceError)
  case quoteLoaded(category: String, quote: Quote)
}

private let categoriesLoading = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .categoriesLoading(task) = message
  else { return }

  state = .loading(task: task)
}

private let categoriesLoadingCancelled = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case .categoriesLoadingCancelled = message,
    case let .loading(task) = state
  else { return }

  task.cancel()
  state = .placeholder
}

private let categoriesLoadingFailed = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .categoriesLoadingFailed(error) = message
  else { return }

  state = .failed(message: error.description)
}

private let categoriesLoaded = ApplicationReducer(path: \.categories) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .categoriesLoaded(categories) = message
  else { return }

  state = .available(categories.sorted { $0.title < $1.title })
}

private let quoteLoading = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoading(category, task) = message
  else { return }

  state[category] = .loading(task: task)
}

private let quoteLoadingCancelled = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoadingCancelled(category) = message,
    let resource = state[category],
    case let .loading(task) = resource
  else { return }

  task.cancel()
  state[category] = .placeholder
}

private let quoteLoadingFailed = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoadingFailed(category, error) = message
  else { return }

  state[category] = .failed(message: error.description)
}

private let quoteLoaded = ApplicationReducer(path: \.quotes) { state, message in
  guard
    let message = message as? QuoteMessage,
    case let .quoteLoaded(category, quote) = message
  else { return }

  state[category] = .available(quote)
}

let quoteMessageHandler = ApplicationMessageHandler(
  reducer: categoriesLoading <> categoriesLoadingCancelled <> categoriesLoadingFailed <> categoriesLoaded
    <> quoteLoading <> quoteLoadingCancelled <> quoteLoadingFailed <> quoteLoaded
)
