import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(WrenTests       .allTests),
    testCase(DynamicWrenTests.allTests)
  ]
}
#endif
