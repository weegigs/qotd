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

protocol QuoteServiceContainer {
  var quotes: QuoteService { get }
}

public enum QuoteServiceError: Error, CustomStringConvertible {
  case unexpectedFailure(Error)
  case invalidEndpoint
  case invalidResponse
  case invalidStatusCode(Int)
  case decodeError(Error)
  case apiError(String)

  public var description: String {
    switch self {
    case let .unexpectedFailure(error):
      return error.localizedDescription
    case let .invalidStatusCode(code):
      return "invalid status code: \(code)"
    case let .decodeError(error):
      return error.localizedDescription
    case let .apiError(error):
      return error
    default:
      return ""
    }
  }
}

protocol QuoteService {
  func categories(fulfill: @escaping (Result<[QuoteCategory], QuoteServiceError>) -> Void) -> Cancellable
  func qod(category: String, fulfill: @escaping (Result<Quote, QuoteServiceError>) -> Void) -> Cancellable
}
