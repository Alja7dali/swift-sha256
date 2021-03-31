// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SHA256",
  products: [
    .library(name: "SHA256", targets: ["SHA256"]),
  ],
  dependencies: [
    .package(url: "https://github.com/alja7dali/swift-bits.git", from: "1.0.0"),
    .package(url: "https://github.com/alja7dali/swift-base16.git", from: "1.0.0"),
  ],
  targets: [
    .target(name: "SHA256", dependencies: ["Bits", "Base16"]),
    .testTarget(name: "SHA256Tests", dependencies: ["SHA256"]),
  ]
)
