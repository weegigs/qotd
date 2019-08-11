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

import XCTest

import Combine
@testable import QOTD
import WeeDux

class QuoteMessageTests: XCTestCase {
  var model: ApplicationModel!

  override func setUp() {
    model = ApplicationModel()
  }

  override func tearDown() {
    model = nil
  }

  func testHandleCategoriesLoading() {
    let task = TestCancelable()

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoading(task: task)
    )

    switch model.categories {
    case .loading:
      XCTAssertFalse(task.cancelled)
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }

  func testHandleCategoriesLoadingFailure() {
    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoadingFailed(error: .apiError("test"))
    )

    switch model.categories {
    case let .failed(message):
      XCTAssertEqual(message, "test")
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }

  func testHandleCategoriesLoadingCancelled() {
    let task = TestCancelable()
    model.categories = .loading(task: task)

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoadingCancelled
    )

    switch model.categories {
    case .placeholder:
      XCTAssertTrue(task.cancelled)
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }

  func testCancelShouldNotAffectAvailable() {
    model.categories = .available([])

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoadingCancelled
    )

    switch model.categories {
    case .available:
      break
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }

  func testCancelShouldNotAffectFailed() {
    model.categories = .failed(message: "test")

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoadingCancelled
    )

    switch model.categories {
    case .failed:
      break
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }

  func testHandleCategoriesLoaded() {
    let categories = [
      QuoteCategory(id: "b", title: "B"),
      QuoteCategory(id: "a", title: "A"),
    ]
    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoaded(categories: categories)
    )

    switch model.categories {
    case let .available(update):
      XCTAssertEqual(update.map { $0.id }.sorted(), categories.map { $0.id }.sorted())
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }

  func testCategoriesLoadedSortsByTitle() {
    let categories = [
      QuoteCategory(id: "b", title: "B"),
      QuoteCategory(id: "a", title: "A"),
    ]
    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.categoriesLoaded(categories: categories)
    )

    switch model.categories {
    case let .available(update):
      XCTAssertEqual("A", update.first!.title)
      XCTAssertEqual("B", update.last!.title)
    default:
      XCTFail("categories in unexpected state \(model.categories)")
    }
  }
}
