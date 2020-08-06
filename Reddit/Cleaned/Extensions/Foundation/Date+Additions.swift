//
//  Date+Additions.swift
//  Reddit
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension Date {

  var timeAgo: String {
    return StringUtils.timeAgoSince(self)
  }

}
