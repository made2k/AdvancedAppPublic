//
//  RemindSwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class RemindSwipeTrigger: NSObject, SwipeTrigger {
  
  let color: UIColor = R.color.swipeYellow().unsafelyUnwrapped
  let view: SwipeCellTriggerableView = ImageTriggerableView(image: R.image.icon_time().unsafelyUnwrapped)
  let mode: SwipeCellNodeMode = .none
  
  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let self = self else { return }

    ReminderTimeViewController.showReminder(type: self.type,
                                            url: self.url,
                                            body: self.body)
  }

  private let type: ReminderType
  private let url: URL
  private let body: String
  
  init(type: ReminderType, url: URL, notificationBody: String) {
    self.type = type
    self.url = url
    self.body = notificationBody
  }
  
}
