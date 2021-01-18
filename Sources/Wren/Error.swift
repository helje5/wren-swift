//
//  WrenError.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren

public extension WrenVM {
 
  struct WrenError: Swift.Error, Equatable {
  
    public enum WrenErrorType: String, Equatable {
      case compile, runtime, stacktrace, unknown
    }
  
    public let type    : WrenErrorType
    public let module  : String
    public let line    : Int
    public let message : String
  }
}

extension WrenVM.WrenError: CustomStringConvertible {
  
  @inlinable
  public var description: String {
    return "<WrenError[\(type.rawValue)]: \(module):\(line): \(message)>"
  }
}

extension WrenVM.WrenError.WrenErrorType: CustomStringConvertible {

  @inlinable
  public var description: String { return rawValue }
}

internal extension WrenVM.WrenError {
 
  init(error   : CWren.WrenErrorType,
       module  : UnsafePointer<CChar>?,
       line    : Int32,
       message : UnsafePointer<CChar>?)
  {
    switch error {
      case WREN_ERROR_COMPILE     : type = .compile
      case WREN_ERROR_RUNTIME     : type = .runtime
      case WREN_ERROR_STACK_TRACE : type = .stacktrace
      default:
        assertionFailure("unexpected Wren error: \(error)")
        type = .unknown
    }
    self.message = message.flatMap({ String(cString: $0) }) ?? ""
    self.module  = module .flatMap({ String(cString: $0) }) ?? ""
    self.line    = Int(line)
  }
}

