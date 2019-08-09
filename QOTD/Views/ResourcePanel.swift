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

import SwiftUI

struct ResourcePanel<T, Content, Loading, Failed, PlaceHolder>: View
  where Content: View, Loading: View, Failed: View, PlaceHolder: View {
  let status: Resource<T>
  let placeholder: () -> PlaceHolder
  let loading: () -> Loading
  let failed: () -> (String) -> Failed
  let render: (T) -> Content

  private func renderLoading() -> AnyView {
    AnyView(loading())
  }

  private func renderFailed(_ message: String) -> AnyView {
    AnyView(failed()(message))
  }

  private func renderBody(_ model: T) -> AnyView {
    AnyView(render(model))
  }

  private func renderPlaceholder() -> AnyView {
    AnyView(placeholder())
  }

  init(
    _ status: Resource<T>,
    placeholder: @escaping @autoclosure () -> PlaceHolder,
    loading: @escaping @autoclosure () -> Loading,
    failed: @escaping @autoclosure () -> (String) -> Failed,
    render: @escaping (T) -> Content
  ) {
    self.status = status
    self.placeholder = placeholder
    self.loading = loading
    self.failed = failed
    self.render = render
  }

  var body: some View {
    switch status {
    case .placeholder:
      return renderPlaceholder()
    case .loading:
      return renderLoading()
    case let .failed(message):
      return renderFailed(message)
    case let .available(resource):
      return renderBody(resource)
    }
  }
}

extension ResourcePanel where Loading == DefaultResourceLoading, Failed == DefaultResourceFailed, PlaceHolder == DefaultResourcePlaceholder {
  init(
    _ status: Resource<T>,
    render: @escaping (T) -> Content
  ) {
    self.init(
      status,
      placeholder: DefaultResourcePlaceholder(),
      loading: DefaultResourceLoading(),
      failed: { message in DefaultResourceFailed(message: message) },
      render: render
    )
  }
}

extension ResourcePanel where Loading == Color, Failed == Color, PlaceHolder == Color {
  enum Style {
    case hidden
  }

  init(
    _ status: Resource<T>,
    style _: Style,
    render: @escaping (T) -> Content
  ) {
    self.init(
      status,
      placeholder: Color.clear,
      loading: Color.clear,
      failed: { _ in Color.clear },
      render: render
    )
  }
}

struct DefaultResourceLoading: View {
  var body: some View {
    ActivityIndicator(isAnimating: .constant(true), style: .large)
  }
}

struct DefaultResourcePlaceholder: View {
  var body: some View {
    Color.clear
  }
}

struct DefaultResourceFailed: View {
  let message: String

  var body: some View {
    VStack {
      Text("Failed to load")
        .padding([.bottom])
      Text(message)
    }
  }
}
