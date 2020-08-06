//
//  ReminderTimeViewController+Static.swift
//  Reddit
//
//  Created by made2k on 9/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftEntryKit

extension ReminderTimeViewController {

  static func showReminder(type: ReminderType, url: URL, body: String) {

    firstly {
      UNUserNotificationCenter.current().authorize()

    }.done {
      presentPicker(type: type, url: url, body: body)

    }.catch { _ in
      showNotificationError()
    }

  }

  private static func presentPicker(type: ReminderType, url: URL, body: String) {

    let controller = ReminderTimeViewController.fromStoryboard(type: type, url: url, body: body)

    var attributes = EKAttributes.centerFloat

    attributes.position = EKAttributes.Position.center
    attributes.positionConstraints.size = .init(width: .ratio(value: 0.9),
                                                height: .intrinsic)
    attributes.positionConstraints.maxSize = .init(width: .constant(value: 375),
                                                   height: .ratio(value: 0.9))

    attributes.entryInteraction = .absorbTouches
    attributes.displayDuration = .infinity
    attributes.screenBackground = .color(color: .init(light: UIColor.black.withAlphaComponent(0.3),
                                                      dark: UIColor.white.withAlphaComponent(0.1)))
    attributes.roundCorners = .all(radius: 10)


    SwiftEntryKit.display(entry: controller, using: attributes)

  }

  private static func fromStoryboard(type: ReminderType, url: URL, body: String) -> ReminderTimeViewController {
    let controller = R.storyboard.reminders.reminderViewController().unsafelyUnwrapped
    controller.setProperties(type: type, url: url, body: body)
    return controller
  }

  private static func showNotificationError() {

    let alert = UIAlertController(title: "Notifications Blocked",
                                  message: "Notifications need to be enabled to schedule reminders",
                                  preferredStyle: .alert)
    alert.addAction(title: "Cancel")
    alert.addAction(title: "Settings") { _ in
      UIApplication.openApplicationSettings()
    }

    alert.show()

  }

}
