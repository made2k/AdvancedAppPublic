//
//  Collection+Additions.swift
//  Reddit
//
//  Created by made2k on 5/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension Collection {
  
  /// Returns the element at the specified index iff it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
  
}
