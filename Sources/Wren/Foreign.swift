//
//  Foreign.swift
//  Wren
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWren

public extension WrenVM {
  
  // https://wren.io/embedding/storing-c-data.html
  // - this has a Wren declaration like:
  //     foreign class File {
  //       construct create(path) {}
  //
  //       foreign write(text)
  //       foreign close()
  //     }
  // - and a C side setup
  
  struct Foreign {
    
    let vm     : WrenVM
    let handle : UnsafeMutableRawPointer
  }
}
