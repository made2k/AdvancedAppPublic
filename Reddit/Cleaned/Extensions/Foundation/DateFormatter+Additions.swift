//
//  DateFormatter+Additions.swift
//  Reddit
//
//  Created by made2k on 5/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension DateFormatter {
  
  convenience init(timeStyle: DateFormatter.Style) {
    self.init()
    self.timeStyle = timeStyle
  }
  
  convenience init(dateStyle: DateFormatter.Style) {
    self.init()
    self.dateStyle = dateStyle
  }

}
