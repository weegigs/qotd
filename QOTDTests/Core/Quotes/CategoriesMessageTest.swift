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
import SwifTEA

class CategoriesMessageTests: XCTestCase {
  var model: ApplicationModel.Categories = .placeholder

  override func setUp() {
    model = .placeholder
  }

  override func tearDown() {
    model = .placeholder
  }

  func testHandleCategoriesLoading() {
    let task = TestCancelable()

    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoading(task: task)
    )

    switch model {
    case .loading:
      XCTAssertFalse(task.cancelled)
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }

  func testHandleCategoriesLoadingFailure() {
    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoadingFailed(error: .apiError("test"))
    )

    switch model {
    case let .failed(message):
      XCTAssertEqual(message, "test")
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }

  func testHandleCategoriesLoadingCancelled() {
    let task = TestCancelable()
    model = .loading(task: task)

    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoadingCancelled
    )

    switch model {
    case .placeholder:
      XCTAssertTrue(task.cancelled)
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }

  func testCancelShouldNotAffectAvailable() {
    model = .available([])

    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoadingCancelled
    )

    switch model {
    case .available:
      break
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }

  func testCancelShouldNotAffectFailed() {
    model = .failed(message: "test")

    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoadingCancelled
    )

    switch model {
    case .failed:
      break
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }

  func testHandleCategoriesLoaded() {
    let categories = [
      QuoteCategory(id: "b", title: "B"),
      QuoteCategory(id: "a", title: "A"),
    ]
    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoaded(categories: categories)
    )

    switch model {
    case let .available(update):
      XCTAssertEqual(update.map { $0.id }.sorted(), categories.map { $0.id }.sorted())
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }

  func testCategoriesLoadedSortsByTitle() {
    let categories = [
      QuoteCategory(id: "b", title: "B"),
      QuoteCategory(id: "a", title: "A"),
    ]
    _ = categoriesMessageHandler.run(
      state: &model,
      message: CategoriesMessage.categoriesLoaded(categories: categories)
    )

    switch model {
    case let .available(update):
      XCTAssertEqual("A", update.first!.title)
      XCTAssertEqual("B", update.last!.title)
    default:
      XCTFail("categories in unexpected state \(model)")
    }
  }
}
