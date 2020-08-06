//
//  Distinguished+Additions.swift
//  Reddit
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension Distinguished {

  var color: UIColor {

    switch self {
    case .moderator:
      return R.color.moderatorText().unsafelyUnwrapped

    case .admin:
      return R.color.adminText().unsafelyUnwrapped

    case .submitter:
      return R.color.submitterText().unsafelyUnwrapped

    }

  }

}
