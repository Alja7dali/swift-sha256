import XCTest

import SHA256Tests

var tests = [XCTestCaseEntry]()
tests += SHA256Tests.allTests()
XCTMain(tests)
