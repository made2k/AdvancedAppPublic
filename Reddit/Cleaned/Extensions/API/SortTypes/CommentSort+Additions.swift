//
//  CommentSort+Additions.swift
//  Reddit
//
//  Created by made2k on 4/14/18.
//  Copyright © 2017 made2k. All rights reserved.
//

import RedditAPI

extension CommentSort {
  
  var displayName: String {

    switch self {
    case .confidence: return "Best"
    case .hot: return "Hot"
    case .new: return "New"
    case .controversial: return "Controversial"
    case .old: return "Old"
    case .top: return "Top"
    }

  }

  var icon: UIImage {

    switch self {
    case .confidence: return R.image.icon_best().unsafelyUnwrapped
    case .hot: return R.image.icon_hot().unsafelyUnwrapped
    case .new: return R.image.icon_new().unsafelyUnwrapped
    case .controversial: return R.image.icon_controversal().unsafelyUnwrapped
    case .old: return R.image.icon_time().unsafelyUnwrapped
    case .top: return R.image.icon_top().unsafelyUnwrapped
    }

  }

}
