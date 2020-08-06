//
//  Int+Formatting.swift
//  Reddit
//
//  Created by made2k on 1/26/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation

extension Int {
  
  func asByteSize() -> String {
    let byteCountFormatter =  ByteCountFormatter()
    byteCountFormatter.allowedUnits = .useAll
    return byteCountFormatter.string(for: self) ?? "N/A"
  }
  
}

extension UInt {

  func asByteSize() -> String {
    return Int(self).asByteSize()
  }

}

extension Int64 {

  func asByteSize() -> String {
    return Int(self).asByteSize()
  }

}
