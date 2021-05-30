import XCTest

import UnitTestsGeneratorTests

var tests = [XCTestCaseEntry]()
tests += UnitTestsGeneratorTests.allTests()
XCTMain(tests)
