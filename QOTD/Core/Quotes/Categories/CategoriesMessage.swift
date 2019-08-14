//
//  CategoriesMessage.swift
//  QOTD
//
//  Created by Kevin O'Neill on 13/8/19.
//  Copyright © 2019 Kevin O'Neill. All rights reserved.
//

import Combine
import SwifTEA

enum CategoriesMessage {
  case categoriesLoading(task: Cancellable)
  case categoriesLoadingCancelled
  case categoriesLoadingFailed(error: QuoteServiceError)
  case categoriesLoaded(categories: [QuoteCategory])
}

typealias CategoriesMessageHandler = MessageHandler<QuoteEnvironment, ApplicationModel.Categories, CategoriesMessage>

private let categoriesLoading: CategoriesMessageHandler = .reducer { state, message in
  guard
    case let .categoriesLoading(task) = message
  else { return }

  state = .loading(task: task)
}

private let categoriesLoadingCancelled: CategoriesMessageHandler = .reducer { state, message in
  guard
    case .categoriesLoadingCancelled = message,
    case let .loading(task) = state
  else { return }

  task.cancel()
  state = .placeholder
}

private let categoriesLoadingFailed: CategoriesMessageHandler = .reducer { state, message in
  guard
    case let .categoriesLoadingFailed(error) = message
  else { return }

  state = .failed(message: error.description)
}

private let categoriesLoaded: CategoriesMessageHandler = .reducer { state, message in
  guard
    case let .categoriesLoaded(categories) = message
  else { return }

  state = .available(categories.sorted { $0.title < $1.title })
}

let categoriesMessageHandler = categoriesLoading <> categoriesLoadingCancelled <> categoriesLoadingFailed <> categoriesLoaded
