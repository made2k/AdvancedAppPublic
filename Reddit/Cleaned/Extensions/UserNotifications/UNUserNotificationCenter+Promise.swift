//
//  UNUserNotificationCenter+Promise.swift
//  Reddit
//
//  Created by made2k on 9/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import UserNotifications

extension UNUserNotificationCenter {

  func add(_: PMKNamespacer, _ request: UNNotificationRequest) -> Promise<Void> {

    return Promise { seal in

      add(request) { error in

        if let error = error {
          seal.reject(error)

        } else {
          seal.fulfill(())
        }

      }

    }

  }

  func authorize() -> Promise<Void> {

    return Promise { seal in

      self.requestAuthorization(options: [.alert, .sound]) { (granted, error) in

        guard granted else {
          let error = error ?? PermissionError.notPermitted
          return seal.reject(error)
        }

        seal.fulfill(())
      }
    }

  }

  func checkAuthorized() -> Promise<Void> {

    return Promise { seal in

      self.getNotificationSettings { settings in

        if settings.authorizationStatus == .authorized {
          return seal.fulfill(())

        } else {
          return seal.reject(PermissionError.notPermitted)
        }

      }
    }

  }

}
