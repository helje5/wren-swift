import XCTest
@testable import Wren

final class WrenTests: XCTestCase {
  
  func testSimpleCompile() throws {
    let vm = WrenVM()
    try vm.interpret(
      """
      System.print("I'm running in a VM!")
      """
    )
  }
  
  func testSlotEnsure() throws {
    let vm = WrenVM()
    vm.slots.ensureCapacity(4)
    vm.slots[bool   : 0] = true
    vm.slots[string : 1] = "Hello!"
    vm.slots[double : 2] = 42.1337
    vm.slots[data   : 3] = Data("World".utf8)
    XCTAssertEqual(vm.slots.count, 4)
  }

  func testSlotTypes() throws {
    let vm = WrenVM()
    vm.slots.ensureCapacity(4)
    XCTAssertEqual(vm.slots.count, 4)
    vm.slots[bool   : 0] = true
    vm.slots[string : 1] = "Hello!"
    vm.slots[double : 2] = 42.1337
    vm.slots[data   : 3] = Data("World".utf8)
    XCTAssertEqual(vm.slots[type: 0], .bool)
    XCTAssertEqual(vm.slots[type: 1], .string)
    XCTAssertEqual(vm.slots[type: 2], .number)
    XCTAssertEqual(vm.slots[type: 3], .number) // TBD
  }
  
  func testSlotLists() throws {
    let vm = WrenVM()
    vm.slots.ensureCapacity(4)
    XCTAssertEqual(vm.slots.count, 4)

    vm.slots[string: 0] = "Hello"
    vm.slots[string: 1] = "World"
    vm.slots.createList(in: 2)
    vm.slots.insert(0, into: 0, in: 2)
    vm.slots.insert(1, into: 1, in: 2)
  }

  func testSystemCall() throws {
    let vm = WrenVM()
    
    // make sure we have a `main` module
    try vm.interpret("", in: "main")

    // This must happen before each call, i.e. it's gone after calling
    // `interpret`
    vm.slots.ensureCapacity(4)
    XCTAssertEqual(vm.slots.count, 4)

    // Lookup variable 'System' and put it into slot[0] (the receiver)
    vm.slots.copy("System", in: "main", into: 0)
    XCTAssertEqual(vm.slots[type: 0], .unknown)
    
    // Put the single argument into slot 1
    vm.slots[string: 1] = "Hey you!"
    
    // Grab a selector for the method we want to call
    guard let sel = vm.makeSignature("print(_)") else {
      XCTAssert(false, "could not get signature for `print(_)`")
      return
    }
    
    // call it
    try vm.call(with: sel)
    
    // grab the result: print seems to return the string it printed
    XCTAssertEqual(vm.slots[type: 0], .string)
    XCTAssertEqual(vm.slots[string: 0], "Hey you!")
  }
  
  func testSyntaxErrorThrow() {
    let vm = WrenVM()
    do { // semicolon is the error, great!
      try vm.interpret(
        """
        System.print("I'm running in a VM!");
        """
      )
      XCTAssert(false, "syntax error did not trigger error")
    }
    catch let error as WrenVM.WrenError {
      XCTAssertEqual(error.type   , .compile)
      XCTAssertEqual(error.line   , 1)
      XCTAssertEqual(error.module , "main")
      XCTAssert(error.message.contains("Error"))
      XCTAssert(error.message.contains(";"))
    }
    catch {
      XCTAssert(error is WrenVM.WrenError,
                "got some other, unexpected error: \(error)")
    }
  }

  static var allTests = [
    ( "testSimpleCompile"    , testSimpleCompile    ),
    ( "testSlotEnsure"       , testSlotEnsure       ),
    ( "testSlotTypes"        , testSlotTypes        ),
    ( "testSlotLists"        , testSlotLists        ),
    ( "testSystemCall"       , testSystemCall       ),
    ( "testSyntaxErrorThrow" , testSyntaxErrorThrow )
  ]
}
