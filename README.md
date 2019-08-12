# QOTD

![Screenshot](ipad-screenshot.png)

An example app using SwiftUI, SwifTEA and SwifTEAUI.

## Overview

SwiftUI gives us the opportunity to exploit unidirectional data flow within iOS and related platforms. The QOTD application shows how to use [WeeDux](https://github.com/weegigs/weedux) to drive SwiftUI and explores the ergonomics of the solution.

QOTD uses the free API from [theysaidso.com](https://theysaidso.com/api/). The free version places significant access limitations (10 calls an hour) without a key. While this would not be ideal for a production application it great in our purposes as it allows us to explore error handing and retries.

## Examples

- [X] Creating a `Program` and `Model` with persistence support
- [X] Using `Message`s to drive `View` updates
- [X] Service access via `Command`s
- [X] Remote images with stateless components
- [X] Displaying errors when a resource loading fails
- [X] Cancelling work when a `View` disappears
- [ ] Control interactions
- [X] Unit Test example for MessageHandlers
- [ ] Unit Test example for Commands
- [ ] Unit Test example for Views

>At the time of writing a bug is `SwiftUI` is preventing the `onDisappear` method
being called. This prevents the various cancel messages from being fired.

If there are any other examples you'd like to see, please let me know.

## Slides

The slides from my talk at CocoaHeads Melbourne can be found at [SwifTEA UI - Unidirectional dataflow with SwiftUI and WeeDux](https://www.slideshare.net/KevinONeill1/swiftea-ui-unidirectional-data-flow-with-swiftui-and-weedux)

## Licence

MIT License

Copyright (c) 2019 Kevin O'Neill

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
