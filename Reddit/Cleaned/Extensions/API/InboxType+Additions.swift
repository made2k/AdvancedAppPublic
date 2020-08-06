//
//  InboxType+Additions.swift
//  Reddit
//
//  Created by made2k on 6/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI
import UIKit

extension InboxType {

  var icon: UIImage {
    switch self {
    case .inbox:
      return R.image.icon_mail().unsafelyUnwrapped
    case .unread:
      return R.image.icon_mail_unread().unsafelyUnwrapped
    case .sent:
      return R.image.icon_sent().unsafelyUnwrapped
    }
  }

  var title: String {
    switch self {
    case .inbox:
      return "Inbox"
    case .unread:
      return "Unread"
    case .sent:
      return "Sent"
    }
  }
}
