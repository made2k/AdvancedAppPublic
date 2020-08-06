//
//  Int+Additions.swift
//  Utilities
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation

extension Int {
  
  public var seconds: TimeInterval {
    return TimeInterval(self)
  }
  
  public var minutes: TimeInterval {
    return TimeInterval(self * 60)
  }
  
  public var hours: TimeInterval {
    return minutes * 60
  }
  
  public var days: TimeInterval {
    return hours * 24
  }
  
  public var week: TimeInterval {
    return days * 7
  }
}

extension Int {

  public func indexPaths(section: Int, starting: Int = 0) -> [IndexPath] {

    var indexes: [IndexPath] = []
    for i in 0..<self {
      indexes.append(IndexPath(row: starting + i, section: section))
    }

    return indexes
  }
}
