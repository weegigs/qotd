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
import Foundation
import UIKit

protocol ImageServiceContainer {
  var images: ImageService { get }
}

enum ImageServiceError: Error, CustomStringConvertible {
  case unknownError(error: Error)
  case internalError(message: String)
  case invalidURL(url: String)
  case invalidResponse(message: String)

  var description: String {
    switch self {
    case let .unknownError(error):
      return error.localizedDescription
    case let .internalError(message):
      return "internal error: \(message)"
    case let .invalidURL(url):
      return "invalid url: \(url)"
    case let .invalidResponse(message):
      return "invalid response: \(message)"
    }
  }
}

protocol ImageService {
  func load(url: URL, fulfill: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable
}

extension ImageService {
  func load(url location: String, fulfill: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable {
    guard let url = URL(string: location) else {
      fulfill(.failure(.invalidURL(url: location)))
      return AnyCancellable {}
    }

    return load(url: url, fulfill: fulfill)
  }
}
