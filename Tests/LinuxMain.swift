import XCTest

import CWrenTests
import WrenTests

var tests = [ XCTestCaseEntry ]()
tests += CWrenTests.allTests()
tests += WrenTests .allTests()
XCTMain(tests)
