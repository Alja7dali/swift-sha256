import XCTest
@testable import SHA256

final class SHA256Tests: XCTestCase {
  func testSHA256() {
    do {
      let hashed = SHA256.hash("Hello, World!".makeBytes())
      let hashedString = try String(hashed)
      XCTAssertEqual(hashedString, "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f")
    } catch {
      print(error)
      XCTFail()
    }
  }

  static var allTests = [
    ("testSHA256", testSHA256),
  ]
}
