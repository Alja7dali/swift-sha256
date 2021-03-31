###### This is an implementation of [SHA256](https://en.wikipedia.org/wiki/SHA256) `hash` algorithm.

#### Example:

```swift
import SHA256

/// Hash to SHA256
/// 1. convert string to bytes (utf8 format)
let bytes = "Hello, World!".makeBytes()
/// 2. hash bytes using sha256 digesting algorithm
let hashedBytes = SHA256.hash(bytes)
/// 3. converting bytes back to string
let hashedString = try String(hashedBytes) // "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f"
```

#### Importing SHA256:

To include `SHA256` in your project, you need to add the following to the `dependencies` attribute defined in your `Package.swift` file.
```swift
dependencies: [
  .package(url: "https://github.com/alja7dali/swift-sha256.git", from: "1.0.0")
]
```