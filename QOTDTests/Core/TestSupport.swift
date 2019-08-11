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

@testable import QOTD

struct TestEnvironment: ApplicationEnvironment {
  let quotes: QuoteService
  let imageService: ImageService

  init(
    categories: @escaping TestQuoteService.LoadCategories = TestQuoteService.Defaults.categories,
    qotd: @escaping TestQuoteService.LoadQOTD = TestQuoteService.Defaults.qotd
  ) {
    quotes = TestQuoteService(categories: categories, qotd: qotd)
    imageService = TestImageService()
  }
}

final class TestImageService: ImageService {
  func load(url _: URL, forfil _: @escaping (Result<UIImage, ImageServiceError>) -> Void) -> Cancellable {
    fatalError()
  }
}

final class TestCancelable: Cancellable {
  private(set) var cancelled: Bool = false

  func cancel() {
    cancelled = true
  }
}

struct TestQuoteService: QuoteService {
  typealias LoadCategories = (@escaping (Result<[QuoteCategory], QuoteServiceError>) -> Void) -> Cancellable
  typealias LoadQOTD = (String, @escaping (Result<Quote, QuoteServiceError>) -> Void) -> Cancellable

  static let Defaults: (categories: LoadCategories, qotd: LoadQOTD) = (
    categories: { $0(.failure(.invalidEndpoint)); return TestCancelable() },
    qotd: { $1(.failure(.invalidEndpoint)); return TestCancelable() }
  )

  private let categories: LoadCategories
  private let qotd: LoadQOTD

  func categories(forfil: @escaping (Result<[QuoteCategory], QuoteServiceError>) -> Void) -> Cancellable {
    categories(forfil)
  }

  func qod(category: String, forfil: @escaping (Result<Quote, QuoteServiceError>) -> Void) -> Cancellable {
    qotd(category, forfil)
  }

  init(
    categories: @escaping LoadCategories = Defaults.categories,
    qotd: @escaping LoadQOTD = Defaults.qotd
  ) {
    self.categories = categories
    self.qotd = qotd
  }
}

func createTestStore(
  categories _: @escaping TestQuoteService.LoadCategories = TestQuoteService.Defaults.categories,
  qotd _: @escaping TestQuoteService.LoadQOTD = TestQuoteService.Defaults.qotd
) -> some ApplicationStore {
  return ApplicationStore(environment: .test {
    TestEnvironment()
  })
}
