//
//  Configuration.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import func Foundation.fwrite
import let  Foundation.stdout

public extension WrenVM {
  
  struct Configuration {
    
    public var write       : ( WrenVM, Data      ) -> Void
    public var recordError : (( WrenVM, WrenError ) -> Void)?

    @inlinable
    public init(write       : @escaping ( WrenVM, Data ) -> Void
                            = Configuration.defaultWrite,
                recordError : (( WrenVM, WrenError ) -> Void)? = nil)
    {
      self.write       = write
      self.recordError = recordError
    }
    
    public static func defaultWrite(vm: WrenVM, data: Data) {
      if let string = String(data: data, encoding: .utf8) {
        print(string)
      }
      else {
        let ok : Int = data.withContiguousStorageIfAvailable({ bp in
          return fwrite(bp.baseAddress, bp.count, 1, stdout)
        })
        ?? data.withUnsafeBytes({ ( rbp: UnsafeRawBufferPointer ) in
          return fwrite(rbp.baseAddress, rbp.count, 1, stdout)
        })
        assert(ok == 1)
      }
    }
  }
}
