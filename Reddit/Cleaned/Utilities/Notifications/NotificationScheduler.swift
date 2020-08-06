//
//  NotificationScheduler.swift
//  Reddit
//
//  Created by made2k on 9/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UserNotifications
import PromiseKit

class NotificationScheduler: NSObject {

  static func scheduleNotification(identifier: String,
                                   title: String,
                                   body: String,
                                   userInfo: [AnyHashable: Any] = [:],
                                   at date: Date) -> Promise<Void> {

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.userInfo = userInfo
    content.sound = .default
    
    // The date must be in the future. Otherwise there's no notification.
    let safeDate = max(date, Date().addingTimeInterval(10))

    let components = Calendar.current.dateComponents([
      .timeZone,
      .year,
      .month,
      .day,
      .hour,
      .minute,
      .second], from: safeDate)

    let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                repeats: false)

    let request = UNNotificationRequest(identifier: identifier,
                                        content: content,
                                        trigger: trigger)

    return UNUserNotificationCenter.current().add(.promise, request)
  }

  static func scheduleNotification(identifier: String,
                                   title: String,
                                   body: String,
                                   userInfo: [AnyHashable: Any] = [:],
                                   timeInterval: TimeInterval) -> Promise<Void> {

    let date = Date().addingTimeInterval(timeInterval)

    return scheduleNotification(identifier: identifier,
                                title: title,
                                body: body,
                                userInfo: userInfo,
                                at: date)
  }


}
