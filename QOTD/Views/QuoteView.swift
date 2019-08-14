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
import SwifTEAUI

struct QuoteViewBody: View {
  let model: QuoteView.ViewModel

  var body: some View {
    ResourcePanel(model.resource) { quote in
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
            Color(UIColor.systemBackground)
              .opacity(0.7)
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
    .onAppear {
      self.model.load(reloadFailure: true)
    }
    .onDisappear {
      self.model.dismissed()
    }
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

      load()
    }

    func load(reloadFailure: Bool = false) {
      guard let quote = quotes[category.id] else {
        return dispatcher.send(QuoteCommands.refreshQOD(category.id))
      }

      quote.load(
        dispatcher.send(QuoteCommands.refreshQOD(category.id)),
        reloadFailure: reloadFailure
      ) { quote in
        guard let image = images[quote.background] else {
          return dispatcher.send(ImageCommands.load(location: quote.background))
        }

        image.load(
          dispatcher.send(ImageCommands.load(location: quote.background)),
          reloadFailure: reloadFailure
        )
      }
    }

    func dismissed() {
      guard let quote = quotes[category.id] else {
        return
      }

      quote.on(
        loading: { dispatcher.send(QuoteMessage.quoteLoadingCancelled(category: category.id)) }
      )

      quote
        .flatMap {
          .available(ImageMessage.cancelled(location: $0.background))
        }
        .on(
          available: { dispatcher.send($0) }
        )
    }

    var background: Resource<UIImage> {
      resource.flatMap { quote in
        images[quote.background] ?? .placeholder
      }
    }

    var resource: Resource<Quote> {
      quotes[category.id] ?? .placeholder
    }

    var title: String {
      category.title
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
