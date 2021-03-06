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
import UIKit

enum ImageMessage {
  case loading(location: String, task: Cancellable)
  case cancelled(location: String)
  case loaded(location: String, image: UIImage)
  case failed(location: String, message: String)
}

typealias ImageMessageHandler = MessageHandler<ImageEnvironment, ApplicationModel.Cache.Images, ImageMessage>

private let loading: ImageMessageHandler = .reducer { state, message in
  guard
    case let .loading(location, task) = message
  else { return }

  state[location] = .loading(task: task)
}

private let cancelled: ImageMessageHandler = .reducer { state, message in
  guard
    case let .cancelled(location) = message,
    let resource = state[location]
  else { return }

  switch resource {
  case let .loading(task):
    task.cancel()
    state[location] = .placeholder
  default:
    break
  }
}

private let loaded: ImageMessageHandler = .reducer { state, message in
  guard
    case let .loaded(location, image) = message
  else { return }

  state[location] = .available(image)
}

private let failed: ImageMessageHandler = .reducer { state, message in
  guard
    case let .failed(location, details) = message
  else { return }

  state[location] = .failed(message: details)
}

let imageMessageHandler = loading <> cancelled <> loaded <> failed
