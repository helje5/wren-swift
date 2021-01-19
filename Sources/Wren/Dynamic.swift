//
//  Dynamic.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren
import struct Foundation.Data

public extension WrenVM {
  // Note: All this should probably use ref types and handels.
  
  @dynamicCallable
  struct VMObjectFunction {
    
    public let vm         : WrenVM
    public let moduleName : String
    public let objectName : String
    public let name       : String
    
    // MARK: - Value Access
    
    func withVariableInSlot0<R>(execute: ( WrenVM.Slots ) throws -> R )
           rethrows -> R
    {
      vm.slots.ensureCapacity(1)
      vm.slots.copy(objectName, in: moduleName, into: 0)
      return try execute(vm.slots)
    }
        
    
    // MARK: - Calls
    
    @discardableResult
    public func dynamicallyCall(withArguments args: [ Value ])
                  throws -> Value
    {
      return try withVariableInSlot0 { slots in
        // FIXME: cache the selector handle :-)
        let signature = (0..<args.count).map({ _ in "_" })
                                        .joined(separator: ",")
        let selector  = "\(name)(\(signature))"
        
        guard let handle = vm.makeSignature(selector) else {
          struct NoSignatureHandle: Swift.Error {}
          throw NoSignatureHandle()
        }
        
        vm.slots.ensureCapacity(args.count + 1)
        for ( i, arg ) in args.enumerated() {
          vm.slots[i + 1] = arg
        }

        try vm.call(with: handle)
        
        return slots[0]
      }
    }
  }
  
  @dynamicMemberLookup
  struct VMModuleMember {
    
    public let vm         : WrenVM
    public let moduleName : String
    public let name       : String
    
    // MARK: - Value Access
    
    func withVariableInSlot0<R>(execute: ( WrenVM.Slots ) throws -> R )
           rethrows -> R
    {
      vm.slots.ensureCapacity(1)
      vm.slots.copy(name, in: moduleName, into: 0)
      return try execute(vm.slots)
    }
    
    public var type : ValueType {
      return withVariableInSlot0 { slots in slots[type: 0] }
    }
    
    public var stringValue : String {
      return withVariableInSlot0 { slots in slots[string: 0] }
    }
    public var doubleValue : Double {
      return withVariableInSlot0 { slots in slots[double: 0] }
    }
    public var dataValue : Data {
      return withVariableInSlot0 { slots in slots[data: 0] }
    }

    
    // MARK: - Function Access
    
    public subscript(dynamicMember key: String) -> VMObjectFunction {
      // TODO: this could also support nested lookups
      return VMObjectFunction(vm: vm,
                              moduleName: moduleName, objectName: name,
                              name: key)
    }
  }
  
  @dynamicMemberLookup
  struct VMModule {
    
    public let vm   : WrenVM
    public let name : String

    public subscript(dynamicMember key: String) -> VMModuleMember {
      return VMModuleMember(vm: vm, moduleName: name, name: key)
    }
  }
}
