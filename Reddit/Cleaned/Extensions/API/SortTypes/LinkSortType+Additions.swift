//
//  LinkSortType+Additions.swift
//  RedditAPI
//
//  Created by made2k on 3/22/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

extension LinkSortType {
  
  var icon: UIImage {
    switch self {
    case .hot: return R.image.icon_hot().unsafelyUnwrapped
    case .new: return R.image.icon_new().unsafelyUnwrapped
    case .rising: return R.image.icon_rising().unsafelyUnwrapped
    case .controversial: return R.image.icon_controversal().unsafelyUnwrapped
    case .top: return R.image.icon_top().unsafelyUnwrapped
    }
  }
  
  var displayName: String {
    switch self {
    case .hot: return "Hot"
    case .new: return "New"
    case .rising: return "Rising"
    case .controversial: return "Controversial"
    case .top: return "Top"
    }
  }
  
}
