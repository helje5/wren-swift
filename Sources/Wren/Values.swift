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
  
  enum ValueType {
    
    /// Called `null` in Wren, `none` in Swift. The `Null` class singleton.
    case none
    
    /// A boolean
    case bool
    
    /// Wren numbers are `Double`s and are represented by the `Num` class.
    case number

    /// Wren strings are arrays of arbitrary bytes, not Swift like String's.
    case string
    
    /// A Foreign is an object declare on the Swift/C side. I.e. a host object.
    case foreign
    
    case list
    case map
    case unknown
  }
  
  /**
   * A value that can travel from an to Wren.
   */
  enum Value {
    
    /// Called `null` in Wren, `none` in Swift. The `Null` class singleton.
    case none
    
    /// A boolean
    case bool(Bool)
    
    /// Wren numbers are `Double`s and are represented by the `Num` class.
    case number(Double)
    
    /// Wren strings are arrays of arbitrary bytes, not Swift like String's.
    case string([ UInt8 ])
    
    /// A Foreign is an object declare on the Swift/C side. I.e. a host object.
    case foreign(Foreign)
    
    // TODO:
    
    case list
    case map
    case unknown

    
    // MARK: - Get the type

    @inlinable
    public var type : WrenVM.ValueType {
      switch self {
        case .bool    : return .bool
        case .number  : return .number
        case .foreign : return .foreign
        case .list    : return .list
        case .map     : return .map
        case .none    : return .none
        case .string  : return .string
        case .unknown : return .unknown
      }
    }
    
    
    // MARK: - Base Types
    
    public var stringValue: String {
      switch self {
        case .bool  (let flag)   : return flag ? "true" : "false"
        case .number(let double) : return String(double)
        case .none               : return ""
        case .string(let data):
          return String(data: Data(data), encoding: .utf8) ?? ""
        case .foreign, .list, .map, .unknown:
          return ""
      }
    }
    
    public var doubleValue: Double {
      switch self {
        case .bool  (let flag)   : return flag ? 1.0 : 0.0
        case .number(let double) : return double
        case .none               : return 0.0
        case .string(let data):
          return Double(String(data: Data(data), encoding: .utf8) ?? "") ?? 0.0
        case .foreign, .list, .map, .unknown:
          return 0.0
      }
    }
  }
}

internal extension WrenVM.ValueType {
  
  init(_ cType: CWren.WrenType) {
    switch cType {
      case WREN_TYPE_BOOL    : self = .bool
      case WREN_TYPE_NUM     : self = .number
      case WREN_TYPE_FOREIGN : self = .foreign
      case WREN_TYPE_LIST    : self = .list
      case WREN_TYPE_MAP     : self = .map
      case WREN_TYPE_NULL    : self = .none
      case WREN_TYPE_STRING  : self = .string
      case WREN_TYPE_UNKNOWN : self = .unknown
      default:
        assertionFailure("unexpected Wren type code: \(cType)")
        self = .unknown
    }
  }
}
