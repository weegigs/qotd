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

import UIKit

enum ImageCommands {
  static func load(location: String) -> ApplicationCommand {
    ApplicationCommand { _, publish in
      guard let url = URL(string: location) else {
        return publish(ImageMessage.failed(location: location, message: "invalid url"))
      }

      let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
        if let error = error {
          return publish(ImageMessage.failed(location: location, message: error.localizedDescription))
        }

        guard
          let response = response as? HTTPURLResponse
        else {
          return publish(ImageMessage.failed(location: location, message: "unexpected result type"))
        }

        guard
          let data = data
        else {
          return publish(ImageMessage.failed(location: location, message: "data unavailable"))
        }

        guard
          200 ..< 299 ~= response.statusCode
        else {
          return publish(ImageMessage.failed(location: location, message: "invalid response code: \(response.statusCode)"))
        }

        guard let image = UIImage(data: data) else {
          return publish(ImageMessage.failed(location: location, message: "failed to decode image"))
        }

        return publish(ImageMessage.loaded(location: location, image: image))
      }

      publish(ImageMessage.loading(location: location))
      task.resume()
    }
  }
}
