import XCTest
@testable import Wren

final class DynamicWrenTests: XCTestCase {
  
  func testSimpleValueCall() throws {
    let vm = WrenVM()
    
    let input = "I'm running in a VM!"
    
    let result =
      try vm.main.System.print(.string([ UInt8 ](input.utf8)))
    
    XCTAssertEqual(result.type        , .string)
    XCTAssertEqual(result.stringValue , input)
  }

  func testSimpleConvertibleCall() throws {
    let vm = WrenVM()
    
    let input  = "I'm running in a VM!"
    let result = try vm.main.System.print(input)
    
    XCTAssertEqual(result.type        , .string)
    XCTAssertEqual(result.stringValue , input)
  }

  static var allTests = [
    ( "testSimpleValueCall" , testSimpleValueCall )
  ]
}
