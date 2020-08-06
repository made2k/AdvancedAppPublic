//
//  TriggerIdentifier.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

enum TriggerIdentifier: String, CustomStringConvertible {
  case upvote = "Upvote"
  case downvote = "Downvote"
  case reply = "Reply"
  case collapse = "Collapse"
  case remind = "Remind"
  case save = "Save"
  case hide = "Hide"
  case markRead = "Mark Read"

  var description: String {
    return rawValue
  }

  var defaultIcon: UIImage {

    switch self {
    case .upvote:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .arrowUp) }
      else { return R.image.icon_upvote().unsafelyUnwrapped }

    case .downvote:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .arrowDown) }
      else { return R.image.icon_downvote().unsafelyUnwrapped }

    case .save:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .bookmark) }
      else { return R.image.icon_save_empty().unsafelyUnwrapped }

    case .collapse:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .arrowUpToLine) }
      else { return R.image.iconCollapse().unsafelyUnwrapped }

    case .hide:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .eyeSlash) }
      else { return R.image.icon_hide().unsafelyUnwrapped }

    case .reply:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .arrowshapeTurnUpLeft) }
      else { return R.image.icon_reply().unsafelyUnwrapped }

    case .remind:
      return R.image.icon_time().unsafelyUnwrapped

    case .markRead:
      if #available(iOS 13.0, *) { return UIImage(systemSymbol: .eye) }
      else { return R.image.icon_hidden().unsafelyUnwrapped }

    }
  }
}
