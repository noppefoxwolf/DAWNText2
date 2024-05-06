# DAWNText2

A powerful and lightweight Text rendering view instead SwiftUI.Text.

# Install

```swift
let package = Package(
    dependencies: [
        .package(url: "<# URL #>", from: "0.0.x")
    ],
)
```

# Usage

## UIKit

```swift
let textView = DAWNTextView()
textView.attributedText = attributedText
```

## SwiftUI

```swift
DAWNText2.TextView(attributedText)
```

# Features

- a12y
- UITraitCollection
- UIColor.tintColor
- NSTextAttachmentViewProvider

# TODO

- [ ] TBD

# Required

- Swift 5.10
- iOS 17.0+

# Apps Using

<p float="left">
    <a href="https://apps.apple.com/app/id1668645019"><img src="https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/a4/90/d4/a490d494-0ba3-9e1f-5c09-cc6ece22d978/AppIcon-1x_U007epad-0-P3-85-220-0.png/512x512bb.jpg" height="65"></a>
</p>

# License

DAWNText2 is available under the MIT license. See the LICENSE file for more info.
