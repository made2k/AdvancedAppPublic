//
//  Dictionary+Additions.swift
//  Reddit
//
//  Created by made2k on 2/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension Dictionary {

  func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
    return Array(self)
      .sorted() {
        let (_, lv) = $0
        let (_, rv) = $1
        return isOrderedBefore(lv, rv)
      }
      .map {
        let (k, _) = $0
        return k
    }
  }
  
}
