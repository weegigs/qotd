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

struct QuoteViewBody: View {
  let model: QuoteView.ViewModel

  var body: some View {
    ResourcePanel(model.status) { quote in
      VStack(alignment: .leading) {
        Spacer()
        CardView {
          VStack {
            Text(quote.quote)
            HStack(alignment: .firstTextBaseline) {
              Spacer()
              Text("-")
              Text(quote.author)
            }.padding([.top, .trailing, .leading])
          }
          .padding()
          .background(
            Color(white: 0.95)
              .opacity(0.6)
              .blur(radius: 5)
          )
        }
        .padding(.bottom, 80)
      }
    }
    .padding()
    .background(
      ResourcePanel(self.model.background, style: .hidden) {
        Image(uiImage: $0)
          .resizable()
          .aspectRatio(contentMode: ContentMode.fill)
      }
    )
    .edgesIgnoringSafeArea(.all)
  }
}

struct QuoteView: View {
  let category: QuoteCategory

  var body: some View {
    ApplicationStateContainer(\.quotes, \.cache.images) { props, dispatcher in
      QuoteViewBody(model: ViewModel(category: self.category, quotes: props.0, images: props.1, dispatcher: dispatcher))
    }
  }

  struct ViewModel {
    let category: QuoteCategory
    let quotes: ApplicationModel.Quotes
    let images: ApplicationModel.Cache.Images
    let dispatcher: ApplicationStore.Dispatcher

    init(category: QuoteCategory, quotes: ApplicationModel.Quotes, images: ApplicationModel.Cache.Images, dispatcher: ApplicationStore.Dispatcher) {
      self.category = category
      self.quotes = quotes
      self.images = images
      self.dispatcher = dispatcher

      refresh()
    }

    func refresh(force: Bool = false) {
      guard let quote = quotes[category.id] else {
        return dispatcher.send(QuoteCommands.refreshQOD(category.id))
      }

      if force {
        return dispatcher.send(QuoteCommands.refreshQOD(category.id))
      }

      switch quote {
      case .failed, .placeholder:
        return dispatcher.send(QuoteCommands.refreshQOD(category.id))
      case let .available(quote):
        refreshBackground(quote: quote, force: force)
      default:
        break
      }
    }

    private func refreshBackground(quote: Quote, force _: Bool = false) {
      guard let image = images[quote.background] else {
        return dispatcher.send(ImageCommands.load(location: quote.background))
      }

      switch image {
      case .failed, .placeholder:
        return dispatcher.send(ImageCommands.load(location: quote.background))
      default:
        break
      }
    }

    var background: Resource<UIImage> {
      status.flatMap { quote in
        images[quote.background] ?? .placeholder
      }
    }

    var status: Resource<Quote> {
      quotes[category.id] ?? .placeholder
    }

    var title: String {
      category.title
    }

    var quote: Quote? {
      guard let status = quotes[category.id],
        case let .available(quote) = status
      else {
        return nil
      }

      return quote
    }
  }
}

#if DEBUG
  struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
      QuoteView(category: QuoteCategory(id: "test", title: "Test"))
    }
  }
#endif
