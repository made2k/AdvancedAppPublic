//
//  AlertAction.swift
//  Reddit
//
//  Created by made2k on 5/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

typealias Action = () -> Void

struct AlertAction {

  let title: String
  let icon: UIImage?
  let hasNext: Bool
  let action: Action?

  init(title: String, icon: UIImage?, hasNext: Bool = false, action: Action?) {
    self.title = title
    self.icon = icon
    self.hasNext = hasNext
    self.action = action
  }

}
