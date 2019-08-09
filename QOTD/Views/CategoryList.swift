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

struct CategoryListBody: View {
  let model: CategoryList.ViewModel

  var body: some View {
    ResourcePanel(model.categories) { categories in
      List {
        ForEach(categories, id: \.id) { category in
          NavigationLink(destination: QuoteView(category: category)) {
            Text(category.title)
          }
        }
      }
    }
    .padding()
    .navigationBarTitle("Quote of the day")
  }
}

struct CategoryList: View {
  struct ViewModel {
    private let dispatcher: ApplicationStore.Dispatcher
    
    let categories: ApplicationModel.Categories
    func refresh(force _: Bool = false) {
      dispatcher.send(QuoteCommands.refreshCategories)
    }

    init(categories: ApplicationModel.Categories, dispatcher: ApplicationStore.Dispatcher) {
      self.categories = categories
      self.dispatcher = dispatcher
    }
  }

  var body: some View {
    ApplicationStateContainer(\.categories) { categories, dispatcher in
      CategoryListBody(model: ViewModel(categories: categories, dispatcher: dispatcher))
    }
  }
}

#if DEBUG
  struct CategoryList_Previews: PreviewProvider {
    static var previews: some View {
      CategoryList()
    }
  }
#endif
