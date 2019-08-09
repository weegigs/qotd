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

final class URLSessionImageService: ImageService {
  private let session: URLSession

  init(session: URLSession = URLSession.shared) {
    self.session = session
  }

  func load(url: URL, forfil: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable {
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
      if let error = error {
        return forfil(.failure(.unknownError(error: error)))
      }

      guard
        let response = response as? HTTPURLResponse
      else {
        return forfil(.failure(.internalError(message: "unexpected result type")))
      }

      guard
        let data = data
      else {
        return forfil(.failure(.invalidResponse(message: "data unavailable")))
      }

      guard
        200 ..< 299 ~= response.statusCode
      else {
        return forfil(.failure(.invalidResponse(message: "invalid response code: \(response.statusCode)")))
      }

      guard let image = UIImage(data: data) else {
        return forfil(.failure(.invalidResponse(message: "failed to decode image")))
      }

      forfil(.success(image))
    }

    task.resume()

    return AnyCancellable {
      task.cancel()
    }
  }
}
