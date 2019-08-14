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

class QuoteMessageTests: XCTestCase {
  var model: ApplicationModel.Quotes = [:]

  override func setUp() {
    model = [:]
  }

  override func tearDown() {
    model = [:]
  }

  func testHandleQuoteLoading() {
    let task = TestCancelable()

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.quoteLoading(category: "test", task: task)
    )

    switch model["test"] {
    case .loading:
      XCTAssertFalse(task.cancelled)
    default:
      XCTFail("quote in unexpected state \(model)")
    }
  }

  func testQuoteLoadingFailure() {
    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.quoteLoadingFailed(category: "test", error: .apiError("test"))
    )

    switch model["test"] {
    case let .failed(message):
      XCTAssertEqual(message, "test")
    default:
      XCTFail("quote in unexpected state \(model)")
    }
  }

  func testQuoteLoadingCanBeCancelled() {
    let task = TestCancelable()
    model["test"] = .loading(task: task)

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.quoteLoadingCancelled(category: "test")
    )

    switch model["test"] {
    case .placeholder:
      XCTAssertTrue(task.cancelled)
    default:
      XCTFail("quote in unexpected state \(model)")
    }
  }

  func testQuoteLoadingDoesntCancelAvailable() {
    model["test"] = .available(Quote(id: "test", quote: "tests are good", author: "test-mc-test", background: ""))

    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.quoteLoadingCancelled(category: "test")
    )

    switch model["test"] {
    case let .available(quote):
      XCTAssertEqual(quote.quote, "tests are good")
    default:
      XCTFail("quote in unexpected state \(model)")
    }
  }

  func testQuotesLoad() {
    _ = quoteMessageHandler.run(
      state: &model,
      message: QuoteMessage.quoteLoaded(category: "test", quote: Quote(id: "test", quote: "tests are good", author: "test-mc-test", background: ""))
    )

    switch model["test"] {
    case let .available(quote):
      XCTAssertEqual(quote.quote, "tests are good")
    default:
      XCTFail("quote in unexpected state \(model)")
    }
  }
}
