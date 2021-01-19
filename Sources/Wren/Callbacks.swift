//
//  Callbacks.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren
import struct Foundation.Data

internal extension WrenVM { // MARK: - Callbacks
  
  func write(_ data: Data) {
    configuration.write(self, data)
  }
  
  func handleError(_ error: WrenError) {
    lastError = error
    configuration.recordError?(self, error)
  }
}

func writeHandler(vm: OpaquePointer?, text: UnsafePointer<CChar>?) {
  let data : Data = {
    guard let text = text else { return Data() }
    let len = strlen(text) // yes, this one is 0-terminated
    let bp  = UnsafeBufferPointer(start: text, count: len)
    return Data(buffer: bp)
  }()
  
  guard let vm = WrenVM.wrapper(for: vm) else {
    print("ERROR: cannot print, missing wrapper:", data)
    assertionFailure("Call w/o wrapper object?!")
    return
  }
  vm.write(data)
}

func errorHandler(vm      : OpaquePointer?,
                  error   : WrenErrorType,
                  module  : UnsafePointer<CChar>?,
                  line    : Int32,
                  message : UnsafePointer<CChar>?)
{
  let error = WrenVM.WrenError(error: error, module: module, line: line,
                               message: message)
  
  guard let vm = WrenVM.wrapper(for: vm) else {
    print("ERROR: cannot emit error, missing wrapper:", error)
    assertionFailure("Call w/o wrapper object?!")
    return
  }
  
  vm.handleError(error)
}


// MARK: - Foreign Methods

func bindForeignMethod(vm        : OpaquePointer?,
                       module    : UnsafePointer<CChar>?,
                       className : UnsafePointer<CChar>?,
                       isStatic  : Bool,
                       selector  : UnsafePointer<CChar>?)
     -> (@convention(c) (OpaquePointer?) -> Void)?
{
  // TBD: How would we do this. The sole argument to the foreign function is
  //      the handle to the VM object. We loose all the context, i.e. className
  //      static, selector.
  //      Presumably we could push it into thread local storage?
  return nil
}

func bindForeignClass(vm        : OpaquePointer?,
                      module    : UnsafePointer<CChar>?,
                      className : UnsafePointer<CChar>?)
     -> WrenForeignClassMethods
{
  // alloc + finalize, both again just plain C funcs w/ the VM pointer, i.e.
  // that is loosing all context.
  return WrenForeignClassMethods(allocate: nil, finalize: nil)
}
