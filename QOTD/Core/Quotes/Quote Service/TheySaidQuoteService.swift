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

final class TheySaidQuoteService: QuoteService {
  private enum Route {
    case categories
    case qod(category: String)

    var path: String {
      switch self {
      case .categories:
        return "qod/categories"
      case .qod:
        return "qod"
      }
    }

    var parameters: [URLQueryItem] {
      switch self {
      case .categories:
        return []
      case let .qod(category):
        return [URLQueryItem(name: "category", value: category)]
      }
    }
  }

  private struct Response<Content>: Codable where Content: Codable {
    let contents: Content
  }

  private struct Quotes: Codable {
    let quotes: [Quote]
  }

  private struct Categories: Codable {
    let categories: [String: String]
  }

  private struct ErrorResponse: Codable {
    struct Message: Codable {
      let code: Int
      let message: String
    }

    let error: Message
  }

  private typealias CatogoriesResponse = Response<Categories>
  private typealias QuoteResponse = Response<Quotes>

  let session = URLSession.shared
  let base = URL(string: "https://quotes.rest/")!
  let decoder = JSONDecoder()

  func categories(forfil: @escaping (Result<[QuoteCategory], QuoteServiceError>) -> Void) -> Cancellable {
    return fetch(CatogoriesResponse.self, from: .categories) {
      forfil($0.map { $0.contents.categories.map { QuoteCategory(id: $0.key, title: $0.value) } })
    }
  }

  func qod(category: String, forfil: @escaping (Result<Quote, QuoteServiceError>) -> Void) -> Cancellable {
    return fetch(QuoteResponse.self, from: .qod(category: category)) {
      forfil($0.flatMap {
        guard let quote = $0.contents.quotes.first else {
          return .failure(.invalidResponse)
        }

        return .success(quote)
      })
    }
  }

  private func fetch<T: Decodable>(_ type: T.Type, from route: Route, forfil: @escaping (Result<T, QuoteServiceError>) -> Void) -> Cancellable {
    guard
      var location = URLComponents(url: base.appendingPathComponent(route.path), resolvingAgainstBaseURL: true)
    else {
      forfil(.failure(.invalidEndpoint))
      return AnyCancellable {}
    }

    location.queryItems = route.parameters
    guard
      let url = location.url
    else {
      forfil(.failure(.invalidEndpoint))
      return AnyCancellable {}
    }

    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = session.dataTask(with: request) { (data, response, error) -> Void in
      if let failure = error {
        return forfil(.failure(.unexpectedFailure(failure)))
      }

      guard
        let response = response as? HTTPURLResponse
      else {
        return forfil(.failure(.invalidResponse))
      }

      guard
        let data = data
      else {
        return forfil(.failure(.invalidResponse))
      }

      guard
        200 ..< 299 ~= response.statusCode
      else {
        guard let message = try? self.decoder.decode(ErrorResponse.self, from: data) else {
          return forfil(.failure(.invalidStatusCode(response.statusCode)))
        }

        return forfil(.failure(.apiError(message.error.message)))
      }

      do {
        let value = try self.decoder.decode(type, from: data)
        return forfil(.success(value))
      } catch {
//        let payload = String(data: data, encoding: .utf8)
//        print(payload ?? "")

        return forfil(.failure(.decodeError(error)))
      }
    }

    task.resume()

    return AnyCancellable {
      task.cancel()
    }
  }
}

extension Future {
  convenience init(fail: Failure) {
    self.init { $0(.failure(fail)) }
  }
}
