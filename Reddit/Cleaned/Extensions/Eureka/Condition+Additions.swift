//
//  Condition+Additions.swift
//  Reddit
//
//  Created by made2k on 8/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

extension Condition {
  
  static func evaluateSwitch(identifier: String, hiddenValue: Bool) -> Condition {
    
    return Condition.function([identifier], { form in
      guard let switchRow = form.rowBy(tag: identifier) as? SwitchRow else { return false }
      return switchRow.value == hiddenValue
    })
    
  }

}
