//
//  Handle.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren

public extension WrenVM {
  
  final class Handle {
    
    let vm     : WrenVM
    let handle : OpaquePointer?
    
    init(vm: WrenVM, handle: OpaquePointer?) {
      self.vm = vm
      self.handle = handle
    }
    
    deinit {
      wrenReleaseHandle(vm.vm, handle)
    }
  }
}

