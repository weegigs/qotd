//
//  CategoriesCommandTest.swift
//  QOTDTests
//
//  Created by Kevin O'Neill on 14/8/19.
//  Copyright © 2019 Kevin O'Neill. All rights reserved.
//

import XCTest

@testable import QOTD

class CategoriesCommandTest: XCTestCase {
  var messages: [CategoriesMessage] = []

  override func setUp() {
    messages = []
  }

  override func tearDown() {
    messages = []
  }

  class Environment: QuoteEnvironment {
    let quotes: QuoteService

    init(load: @escaping TestQuoteService.LoadCategories) {
      quotes = TestQuoteService(
        categories: load
      )
    }
  }

  func createEnvironment(load: @escaping TestQuoteService.LoadCategories) -> Environment {
    Environment(load: load)
  }

  func publish(_ message: CategoriesMessage) {
    messages.append(message)
  }

  func testRefreshCategoriesFail() {
    let expectation = XCTestExpectation(description: "service called")
    let command = CategoriesCommands.refreshCategories
    let environment = createEnvironment { fulfill in
      fulfill(.failure(.apiError("test")))
      expectation.fulfill()
    }

    command.run(environment, publish)
    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(2, messages.count)

    guard
      let first = messages.first,
      case .categoriesLoading = first
    else {
      return XCTFail("expected first message to be categoriesLoading")
    }

    guard
      let second = messages.last,
      case let .categoriesLoadingFailed(error) = second,
      case let .apiError(message) = error
    else {
      return XCTFail("expected second message to be categoriesLoadingFailed")
    }

    XCTAssertEqual("test", message)
  }

  func testRefreshCategoriesLoaded() {
    let expectation = XCTestExpectation(description: "service called")
    let command = CategoriesCommands.refreshCategories
    let category = QuoteCategory(id: "test", title: "Test")
    let environment = createEnvironment { fulfill in
      fulfill(.success([QuoteCategory(id: "test", title: "Test")]))
      expectation.fulfill()
    }

    command.run(environment, publish)
    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(2, messages.count)

    guard
      let first = messages.first,
      case .categoriesLoading = first
    else {
      return XCTFail("expected first message to be categoriesLoading")
    }

    guard
      let second = messages.last,
      case let .categoriesLoaded(categories) = second,
      let delivered = categories.first
    else {
      return XCTFail("expected second message to be categoriesLoaded")
    }

    XCTAssertEqual(1, categories.count)
    XCTAssertEqual(category.id, delivered.id)
    XCTAssertEqual(category.title, delivered.title)
  }
}
