import XCTest
@testable import CWren

fileprivate
func writeHandler(vm: OpaquePointer?, text: UnsafePointer<CChar>?) {
  guard let text = text else { return }
  let str = String(cString: text)
  print("WREN:", str)
}

fileprivate
func errorHandler(vm      : OpaquePointer?,
                  error   : WrenErrorType,
                  module  : UnsafePointer<CChar>?,
                  line    : Int32,
                  message : UnsafePointer<CChar>?)
{
  let message = message.flatMap { String(cString: $0) }
  let module  = module .flatMap { String(cString: $0) }
  print("ERROR: \(module ?? "-"):\(line): \(message ?? "?")")
}


final class CWrenTests: XCTestCase {
  
  func testCSetup() throws {
    // https://wren.io/embedding/configuring-the-vm.html
    var config = WrenConfiguration()
    wrenInitConfiguration(&config)
    
    config.writeFn = writeHandler
    config.errorFn = errorHandler
    
    // copies config
    let vm = wrenNewVM(&config)
    defer { wrenFreeVM(vm) }
    
    let result = wrenInterpret(
      vm, "my_module",
      """
      System.print("I'm running in a VM!")
      """
    )
    
    switch result {
      case WREN_RESULT_COMPILE_ERROR:
        XCTAssertTrue(false, "Compilation failed!")
      case WREN_RESULT_RUNTIME_ERROR:
        XCTAssertTrue(false, "Runtime Error!")
      case WREN_RESULT_SUCCESS:
        print("RESULT IS GOOD")
      default:
        XCTAssert(false, "unexpected result: \(result)")
    }
    XCTAssert(result == WREN_RESULT_SUCCESS)
  }

  static var allTests = [
    ( "testCSetup", testCSetup )
  ]
}
