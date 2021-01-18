//
//  Slots.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren
import struct Foundation.Data

public extension WrenVM {
  
  struct Slots {
    
    let vm : WrenVM
    
    public func ensureCapacity(_ count: Int) {
      wrenEnsureSlots(vm.vm, Int32(count))
    }
    
    public var count : Int {
      return Int(wrenGetSlotCount(vm.vm))
    }
    
    public var isEmpty: Bool { return count < 1 }
    
    
    // MARK: - Types
    
    public subscript(type slotIndex: Int) -> ValueType {
      return ValueType(wrenGetSlotType(vm.vm, Int32(slotIndex)))
    }
    
    
    // MARK: - Handles

    public subscript(handle slotIndex: Int) -> Handle? {
      set {
        wrenSetSlotHandle(vm.vm, Int32(slotIndex), newValue?.handle)
      }
      get {
        return wrenGetSlotHandle(vm.vm, Int32(slotIndex))
                 .flatMap { Handle(vm: vm, handle: $0) }
      }
    }
    
    
    // MARK: - Variables
    
    /**
     * Lookup a top-level variable with the given name and module, and copy the
     * value to the slot provided.
     *
     * Note: Classes are just objects stored in variables, can be used to
     *       lookup classes by name (and call static methods on them).
     *
     * Note: A little slow, better to use handles in loops.
     */
    public func copy(_ variable: String, in module: String,
                     into slotIndex: Int)
    {
      wrenGetVariable(vm.vm, module, variable, Int32(slotIndex))
    }
    
    /**
     * Create a list in the given slot.
     */
    public func createList(in slotIndex: Int) {
      wrenSetSlotNewList(vm.vm, Int32(slotIndex))
    }
    
    /**
     * Inserts the value at `itemIndex` into the `index` of the list stored
     * in the `listSlotIndex`.
     *
     * This accepts negative indices like in Wren, e.g. -1 to append.
     */
    public func insert(_ itemIndex: Int, into index: Int, in listSlotIndex: Int)
    {
      wrenInsertInList(vm.vm, Int32(listSlotIndex), Int32(index),
                       Int32(itemIndex))
    }
    
    /**
     * Copies the value at `itemIndex` into the `index` of the list stored
     * in the `listSlotIndex` (i.e. set a value in a list).
     */
    public func copy(_ itemIndex: Int, into index: Int, in listSlotIndex: Int) {
      wrenSetListElement(vm.vm, Int32(listSlotIndex), Int32(32),
                         Int32(itemIndex))
    }
    /**
     * Copies the value at `index` in the list at `listSlotIndex` into the
     * `itemIndex` (i.e. get a value from a list).
     */
    public func copy(_ listSlotIndex: Int, at index: Int, into itemIndex: Int) {
      wrenGetListElement(vm.vm, Int32(listSlotIndex), Int32(32),
                         Int32(itemIndex))
    }

    public subscript(listCount slotIndex: Int) -> Int {
      get {
        return Int(wrenGetListCount(vm.vm, Int32(slotIndex)))
      }
    }    
    
    
    // MARK: - Foreigns
    
    /**
     * Create a foreign object at the given `slotIndex`, based on the class
     * in `foreignClassSlotIndex`, with the given size.
     */
    public func createForeign(with foreignClassSlotIndex: Int,
                              in slotIndex: Int, size: Int) -> Foreign?
    {
      guard let data = wrenSetSlotNewForeign(vm.vm, Int32(slotIndex),
                                             Int32(foreignClassSlotIndex), size)
       else { return nil }
      return Foreign(vm: vm, handle: data)
    }
    
    public subscript(foreign slotIndex: Int) -> Foreign? {
      guard let data = wrenGetSlotForeign(vm.vm, Int32(slotIndex)) else {
        return nil
      }
      return Foreign(vm: vm, handle: data)
    }
    
    
    // MARK: - Value Lookup

    public subscript(slotIndex: Int) -> Value {
      set {
        switch newValue {
          case .none                 : wrenSetSlotNull(vm.vm, Int32(slotIndex))
          case .bool  (let flag)     : self[bool: slotIndex] = flag
          case .number(let newValue) : self[double: slotIndex] = newValue
          case .string(let newValue) :
            newValue.withContiguousStorageIfAvailable { bp in
              bp.withMemoryRebound(to: Int8.self) { tbp in // ugh
                wrenSetSlotBytes(vm.vm, Int32(slotIndex),
                                 tbp.baseAddress, tbp.count)
              }
            }
            
          // TODO
          case .foreign(_):
            fatalError("Attempt to set foreign slot, use createForeign etc")
          case .list:
            fatalError("Attempt to set list slot, use createList and such")
          case .map:
            fatalError("Attempt to set map slot: IMPLEMENT ME")
            
          case .unknown:
            fatalError("Attempt to set 'unknown' value to slot")
        }
      }
      get {
        let type = ValueType(wrenGetSlotType(vm.vm, Int32(slotIndex)))
        switch type {
          case .none   : return .none
          case .bool   : return .bool(self[bool: slotIndex])
          case .number : return .number(self[double: slotIndex])
          case .string :
            var len : Int32 = 0
            guard let bytes = wrenGetSlotBytes(vm.vm, Int32(slotIndex), &len),
                  len >= 0 else
            {
              return .none
            }
            if len == 0 { return .string([]) }
            let bp = UnsafeBufferPointer(start: bytes, count: Int(len))
            return bp.withMemoryRebound(to: UInt8.self) { bp in
              return .string([ UInt8 ](bp))
            }
            
          case .foreign:
            guard let object = self[foreign: slotIndex] else { return .none }
            return .foreign(object)
            
          // TODO
          case .list:
            fatalError("IMPLEMENT ME")
          case .map:
            fatalError("IMPLEMENT ME")
            
          case .unknown:
            return .unknown
        }
      }
    }

    
    // MARK: - Typed Subscripts
    
    // TBD: make them optional or not? Or add optional versions?
    
    public subscript(bool slotIndex: Int) -> Bool {
      nonmutating set { wrenSetSlotBool(vm.vm, Int32(slotIndex), newValue) }
      get { return wrenGetSlotBool(vm.vm, Int32(slotIndex)) }
    }
    public subscript(double slotIndex: Int) -> Double {
      nonmutating set { wrenSetSlotDouble(vm.vm, Int32(slotIndex), newValue) }
      get { return wrenGetSlotDouble(vm.vm, Int32(slotIndex)) }
    }
    
    public subscript(string slotIndex: Int) -> String {
      nonmutating set { wrenSetSlotString(vm.vm, Int32(slotIndex), newValue) }
      get {
        return wrenGetSlotString(vm.vm, Int32(slotIndex))
                  .flatMap({ String(cString: $0 )})
            ?? ""
      }
    }
    
    public subscript(data slotIndex: Int) -> Data {
      nonmutating set {
        newValue.withContiguousStorageIfAvailable { bp in
          bp.withMemoryRebound(to: Int8.self) { tbp in // ugh
            wrenSetSlotBytes(vm.vm, Int32(slotIndex),
                             tbp.baseAddress, tbp.count)
          }
        }
      }
      get {
        var len : Int32 = 0
        guard let bytes = wrenGetSlotBytes(vm.vm, Int32(slotIndex), &len),
              len > 0 else
        {
          return Data()
        }
        
        let bp = UnsafeBufferPointer(start: bytes, count: Int(len))
        return Data(buffer: bp)
      }
    }
  }
}
