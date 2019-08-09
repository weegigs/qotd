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

enum Resource<T> {
  case placeholder
  case loading
  case failed(String)
  case available(T)
}

extension Resource: Codable where T: Codable {
  enum Discriminator: String, Codable {
    case unavailable
    case available
  }

  enum CodingKeys: String, CodingKey {
    case __type
    case value
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(Discriminator.self, forKey: .__type)
    switch type {
    case .unavailable:
      self = .placeholder
    case .available:
      let value = try container.decode(T.self, forKey: .value)
      self = .available(value)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .placeholder, .loading, .failed:
      try container.encode(Discriminator.unavailable, forKey: .__type)
    case let .available(value):
      try container.encode(Discriminator.available, forKey: .__type)
      try container.encode(value, forKey: .value)
    }
  }
}

extension Resource {
  func map<U>(mapper: (T) -> U) -> Resource<U> {
    switch self {
    case let .failed(message):
      return .failed(message)
    case .placeholder:
      return .placeholder
    case .loading:
      return .loading
    case let .available(value):
      return .available(mapper(value))
    }
  }

  func flatMap<U>(mapper: (T) -> Resource<U>) -> Resource<U> {
    switch self {
    case let .failed(message):
      return .failed(message)
    case .placeholder:
      return .placeholder
    case .loading:
      return .loading
    case let .available(value):
      return mapper(value)
    }
  }
}
