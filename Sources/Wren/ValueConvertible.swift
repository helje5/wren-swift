//
//  ValueConvertible.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import struct Foundation.URL

/**
 * Swift types that can be converted to Wren.
 */
public protocol WrenValueConvertible {
  
  var wrenValue : WrenVM.Value { get }
  
}

extension WrenVM.Value: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return self }
}

extension String: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return .string([ UInt8 ](utf8)) }
}

extension Substring: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return .string([ UInt8 ](utf8)) }
}

extension URL: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return absoluteString.wrenValue }
}

extension Data: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return .string([ UInt8 ](self)) }
}

extension Double: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return .number(self) }
}

extension Int: WrenValueConvertible {
  
  public var wrenValue: WrenVM.Value { return Double(self).wrenValue }
}
