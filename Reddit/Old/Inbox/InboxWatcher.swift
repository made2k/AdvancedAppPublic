//
//  InboxWatcher.swift
//  Reddit
//
//  Created by made2k on 1/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import RealmSwift
import PromiseKit
import UserNotifications
import RedditAPI
import RxCocoa
import Logging

class InboxWatcher: NSObject {
  static let shared = InboxWatcher()

  private var timer: Timer?
  
  private let realm = try! Realm()
  private let inboxModel = InboxModel()
  
  let unreadCount = BehaviorRelay<Int>(value: 0)
  
  private override init() {
    super.init()
    setupTimer()
    checkForUpdates()
    
    NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func configure() {
    // Just need to call init...
  }
  
  func clearUnread() {
    unreadCount.accept(0)
  }
  
  @objc private func didEnterBackground() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc private func didEnterForeground() {
    setupTimer()
  }
  
  private func setupTimer() {
    timer?.invalidate()
    let minutes: TimeInterval = 5 * 60
    timer = Timer.scheduledTimer(withTimeInterval: minutes, repeats: true) { _ in
      self.checkForUpdates()
    }
  }

  private func checkForUpdates() {
    // Get all the messages, and figure any unalerted
    // are shown somewhere in the app. So no need to show them.
    firstly {
      getUnalertedMessages()

    }.done { messages in
      InboxWatcher.sendNotificationOfMessages(messages)

    }.cauterize()
  }

  static func sendNotificationOfMessages(_ messages: [MessageModel]) {
    guard messages.isEmpty == false else { return }
    guard Settings.messageNotification == true else { return }

    let title: String
    let body: String

    if let message = messages.first, messages.count == 1 {
      title = "New Message from \(message.message.author)"
      let parsedHTMLString = message.message.bodyHtml.processHtmlString().string
      body = parsedHTMLString
    } else {
      title = "Unread messages"
      body = "You have \(messages.count) unread messages"
    }

    firstly {
      UNUserNotificationCenter.current().checkAuthorized()

    }.then {
      NotificationScheduler.scheduleNotification(identifier: "UnreadAlert",
                                                 title: title,
                                                 body: body,
                                                 timeInterval: 1)

    }.catch { error in
      log.error("unable to add notification to be triggered", error: error)
    }

  }
  
  private func getAllUnreadMessages() -> Promise<[MessageModel]> {
    inboxModel.setType(.unread)

    return firstly {
      inboxModel.getMessages()

    }.get {
      self.unreadCount.accept($0.count)
    }
  }
  
  func getUnalertedMessages() -> Promise<[MessageModel]> {
    
    let realmQ = DispatchQueue.main
    
    return firstly {
      getAllUnreadMessages()
      
    }.get { messages in
      messages.updateSeen()

    }.map(on: realmQ) { messages -> [MessageModel] in
      // We check our DB for messages we've already alerted about
      let predicate = NSPredicate(format: "(id IN %@)", messages.map { $0.message.name })
      let alreadyAlerted = self.realm.objects(AlertedUnread.self).filter(predicate)

      return messages.filter { message in
        return !alreadyAlerted.contains(where: { $0.id == message.message.name })
      }
    }
  }
}

extension Array where Element: MessageModel {
  
  func updateSeen() {
    DispatchQueue.global(qos: .background).async {
      do {
        let realm = try Realm()
        
        let predicate = NSPredicate(format: "(id IN %@)", self.map { $0.message.name })
        let alreadyAlerted = realm.objects(AlertedUnread.self).filter(predicate)
        
        let newMessages = self.filter { message -> Bool in
          return !alreadyAlerted.contains(where: { $0.id == message.message.name })
        }
        
        let toAdd: [AlertedUnread] = newMessages.map { message in
          let trackedValue = AlertedUnread()
          trackedValue.id = message.message.name
          return trackedValue
        }
        
        try realm.write {
          toAdd.forEach { realm.add($0) }
        }
        
      } catch {
        log.error("Error updating seen messages.", error: error)
      }
    }
  }
  
}
