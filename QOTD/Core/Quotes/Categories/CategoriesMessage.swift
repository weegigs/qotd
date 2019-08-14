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

enum CategoriesMessage {
  case categoriesLoading(task: Cancellable)
  case categoriesLoadingCancelled
  case categoriesLoadingFailed(error: QuoteServiceError)
  case categoriesLoaded(categories: [QuoteCategory])
}

typealias CategoriesMessageHandler = MessageHandler<QuoteEnvironment, ApplicationModel.Categories, CategoriesMessage>

private let categoriesLoading: CategoriesMessageHandler = .reducer { state, message in
  guard
    case let .categoriesLoading(task) = message
  else { return }

  state = .loading(task: task)
}

private let categoriesLoadingCancelled: CategoriesMessageHandler = .reducer { state, message in
  guard
    case .categoriesLoadingCancelled = message,
    case let .loading(task) = state
  else { return }

  task.cancel()
  state = .placeholder
}

private let categoriesLoadingFailed: CategoriesMessageHandler = .reducer { state, message in
  guard
    case let .categoriesLoadingFailed(error) = message
  else { return }

  state = .failed(message: error.description)
}

private let categoriesLoaded: CategoriesMessageHandler = .reducer { state, message in
  guard
    case let .categoriesLoaded(categories) = message
  else { return }

  state = .available(categories.sorted { $0.title < $1.title })
}

let categoriesMessageHandler = categoriesLoading <> categoriesLoadingCancelled <> categoriesLoadingFailed <> categoriesLoaded
