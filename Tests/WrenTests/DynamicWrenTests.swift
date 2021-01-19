import XCTest
@testable import Wren

final class DynamicWrenTests: XCTestCase {
  
  func testSimpleValueCall() throws {
    let vm = WrenVM()
    // make sure we have a `main` module
    try vm.interpret("", in: "main")
    
    let input = "I'm running in a VM!"
    
    let result =
      try vm.main.System.print(.string([ UInt8 ](input.utf8)))
    
    XCTAssertEqual(result.type        , .string)
    XCTAssertEqual(result.stringValue , input)
  }

  static var allTests = [
    ( "testSimpleValueCall" , testSimpleValueCall )
  ]
}
