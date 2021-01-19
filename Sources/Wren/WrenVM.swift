//
//  WrenVM.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren
import struct Foundation.Data

/**
 * This represents a Wren virtual machine.
 *
 * To communicate between Swift and Wren, one can use slots.
 */
@dynamicMemberLookup
public final class WrenVM {
    
  let vm            : OpaquePointer
  let configuration : Configuration
  
  var lastError     : WrenError?
  
  public init(configuration: Configuration = .init()) {
    self.configuration = configuration
    
    // https://wren.io/embedding/configuring-the-vm.html
    var cConfig = CWren.WrenConfiguration()
    wrenInitConfiguration(&cConfig)
    cConfig.writeFn             = writeHandler
    cConfig.errorFn             = errorHandler
    cConfig.bindForeignMethodFn = bindForeignMethod
    cConfig.bindForeignClassFn  = bindForeignClass

    // The cConfig is copied, we don't need to hang on to it.
    guard let vm = wrenNewVM(&cConfig) else {
      fatalError("Could not initialize/allocate wren VM?")
    }
    self.vm = vm
    
    wrenSetUserData(vm, Unmanaged.passUnretained(self).toOpaque())
  }
  deinit {
    wrenFreeVM(vm)
  }
  
  internal static func wrapper(for vm: OpaquePointer?) -> WrenVM? {
    guard let vm = vm                  else { return nil }
    guard let ud = wrenGetUserData(vm) else { return nil }
    return Unmanaged<WrenVM>.fromOpaque(UnsafeMutableRawPointer(ud))
             .takeUnretainedValue()
  }
  
  
  // MARK: - Slots
  
  public var slots : Slots { return Slots(vm: self) }
  
  
  // MARK: - Execution
  
  /**
   * Use `interpret` to load code into the VM, it parses and compiles the
   * source given.
   * 
   * Don't use `interpret` to call into code in the VM.
   *
   * - Parameters:
   *   - script: The Wren script code to parse, compile and inject.
   *   - module: The name of the module to execute the script in,
   *             defaults to `main`.
   * - Throws: A WrenError when something failed.
   */
  public func interpret(_ script: String, in module: String = "main")
                throws
  {
    lastError = nil
    let result = wrenInterpret(vm, module, script)
    defer { lastError = nil }
    
    switch result {
    
      case WREN_RESULT_COMPILE_ERROR:
        if let error = lastError { throw error }
        throw WrenError(type: .compile, module: module, line: 0, message: "")
        
      case WREN_RESULT_RUNTIME_ERROR:
        if let error = lastError { throw error }
        throw WrenError(type: .runtime, module: module, line: 0, message: "")
        
      case WREN_RESULT_SUCCESS:
        assert(lastError == nil)
        break
        
      default:
        assertionFailure("unexpected result: \(result)")
        if let error = lastError { throw error }
    }
  }
  
  /**
   * This returns a Handle for the signature, which is actually the equivalent
   * of an Objective-C/Smalltalk selector in wren.
   *
   * Example signature (same like `add::` in Objective-C):
   *
   *     "add(_,_)"
   * 
   * Cache this for as long as you are using it to avoid unnecessary lookups.
   */
  public func makeSignature(_ signature: String) -> Handle? {
    // TBD: cache them?
    guard let data = wrenMakeCallHandle(vm, signature) else { return nil }
    return Handle(vm: self, handle: data)
  }
  
  /**
   * Low level call to method. To slots need to be setup properly before.
   *
   * Thats is:
   * - slot 0: the receiver (e.g. handle)
   * - slot 1...n: the arguments
   * 
   * After the call slot 0 will contain the return value.
   */
  public func call(with signature: Handle) throws {
    lastError = nil
    let result = wrenCall(vm, signature.handle)
    defer { lastError = nil }
    
    switch result {
    
      case WREN_RESULT_COMPILE_ERROR:
        if let error = lastError { throw error }
        throw WrenError(type: .compile, module: "", line: 0, message: "")
        
      case WREN_RESULT_RUNTIME_ERROR:
        if let error = lastError { throw error }
        throw WrenError(type: .runtime, module: "", line: 0, message: "")
        
      case WREN_RESULT_SUCCESS:
        assert(lastError == nil)
        break
        
      default:
        assertionFailure("unexpected result: \(result)")
        if let error = lastError { throw error }
    }
  }
  
  
  // MARK: - Dynamic Member Lookup
    
  public subscript(dynamicMember key: String) -> VMModule {
    return VMModule(vm: self, name: key)
  }
}

