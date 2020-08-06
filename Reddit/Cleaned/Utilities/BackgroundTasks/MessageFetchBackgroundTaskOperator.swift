//
//  MessageFetchBackgroundTask.swift
//  Reddit
//
//  Created by made2k on 6/10/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import BackgroundTasks
import Logging
import PromiseKit
import UserNotifications

final class MessageFetchBackgroundTaskOperator {

  static let identifier: String = "com.advancedapp.backgroundAppRefresh"

  static func register() {

    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: identifier,
      using: DispatchQueue.global()
    ) { task in
      checkForNewMessages(with: task)
    }

  }

  static func scheduleAppRefresh(timeInterval: TimeInterval) {

    let request = BGAppRefreshTaskRequest(identifier: identifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: timeInterval)

    DispatchQueue.global().async {

      do {
        try BGTaskScheduler.shared.submit(request)

      } catch {
        log.error("Could not schedule app refresh", error: error)
      }

    }

  }

  static func cancelAppRefresh() {
    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
  }

  private static func checkForNewMessages(with task: BGTask) {

    guard Settings.messageNotification else {
      return task.setTaskCompleted(success: false)
    }

    // TODO: Add proper message cancelation to the expiry handler
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    UNUserNotificationCenter.current().getNotificationSettings { settings in

      // If we can't send a notification, no point in making a fetch
      guard settings.authorizationStatus == .authorized else {
        return task.setTaskCompleted(success: false)
      }

      firstly {
        InboxWatcher.shared.getUnalertedMessages()

      }.done { messages in
        InboxWatcher.sendNotificationOfMessages(messages)
        task.setTaskCompleted(success: true)

      }.catch { error in
        task.setTaskCompleted(success: false)
      }

    }

  }

}
