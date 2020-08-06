
//
//  SortTiming.swift
//  RedditAPI
//
//  Created by made2k on 3/22/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

extension TimePeriod {

  var displayName: String {

    switch self {
    case .hour: return "Hour"
    case .day: return "Day"
    case .week: return "Week"
    case .month: return "Month"
    case .year: return "Year"
    case .all: return "All"
    // case .none: return "None"
    }

  }

  var icon: UIImage {
    return R.image.iconCalendar().unsafelyUnwrapped
  }
  
}
