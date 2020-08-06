//
//  AppDelegate.swift
//  Reddit
//
//  Created by made2k on 2/15/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import CocoaLumberjack
import IQKeyboardManagerSwift
import PasscodeLock
import AVKit
import PromiseKit
import UserNotifications
import RxCocoa
import RedditAPI
import Haptica

import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  lazy var passcodeLockPresenter: PasscodeLockPresenter = {
    let configuration = PasscodeConfiguration()
    let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
    return presenter
  }()
  
  var window: UIWindow?

  let queuedSubreddit = BehaviorRelay<SubredditModel?>(value: nil)
  let queuedInbox = BehaviorRelay<Bool>(value: false)
  let queuedURL = BehaviorRelay<URL?>(value: nil)
  
  private var persistentAudio: AVAudioSession?

  private var coordinator: Coordinator?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let migration = MigrationAssistant.shared.migrateIfNeeded()

    _ = FilterPreference.shared
    MarkRead.shared.configure()
    Reachability.shared.configure()
    CacheManager.shared.configure()
    PromiseKit.conf.Q.map = .global()
    Haptic.enabled = Settings.enableFeedback

    Eureka.registerDefaultCellUpdates()

    Settings.setup()

    DTCoreTextStyles.setup()
    
    setupAudioSession()
    setupBackgroundTasks()

    UNUserNotificationCenter.current().delegate = self
    InboxWatcher.shared.configure()
    
    // Setup this so realm is on main thread... Need to fix
    _ = ImageExtractor.shared

    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentCreateViewController.self)
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window

    coordinator = StartupCoordinator(window: window, waitingOn: migration)
    coordinator?.start()

    passcodeLockPresenter.presentPasscodeLock()

    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    
    if let code = RedditAuthHandler.shared.getAccessCode(url: url) {
      return handleOauth(code: code)
    }

    LinkHandler.handleUrl(url)
    
    return true
  }
  
  private func handleOauth(code: String) -> Bool {

    firstly {
      try RedditAuthHandler.shared.requestAccessToken(code: code)

    }.done { (token: Token) in
      guard let newUserName = token.name else { return }

      // Save should happen from the token delegate, if not save here
      if Keychain.shared.userNames.contains(newUserName) == false {
        Keychain.shared.save(token: token)
      }
      Keychain.shared.setPreferedUsername(token.name.unsafelyUnwrapped).cauterize()

    }.catch { error in
      SplitCoordinator.current.topViewController.presentGenericError(error: error, text: "Failed to sign in. Please try again.")
    }

    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    passcodeLockPresenter.presentPasscodeLock()
    
    disposeAudioSession()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    setupAudioSession()
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if
      let displayName = userActivity.userInfo?["subredditDisplayName"] as? String,
      let _ = userActivity.userInfo?["subredditQuery"] as? String,
      userActivity.activityType == "com.advancedapp.Reddit.subredditVisit" {

      firstly {
        SubredditModel.verifySubredditExists(path: displayName)

      }.done {
        self.queuedSubreddit.accept($0)

      }.cauterize()

      return true
    }
    return false
  }

  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    if shortcutItem.type == "OpenSubreddit" {

      firstly {
        SubredditModel.verifySubredditExists(path: shortcutItem.localizedTitle)

      }.done {
        self.queuedSubreddit.accept($0)
      }.cauterize()
      completionHandler(true)

    } else {
      completionHandler(false)
    }
  }

  private func setupAudioSession() {
    guard persistentAudio == nil else { return }
    
    persistentAudio = AVAudioSession()
    
    try? persistentAudio?.setMode(.default)
    try? persistentAudio?.setCategory(.playback , mode: .default, options: .mixWithOthers)
    try? persistentAudio?.setActive(true, options: [])
  }
  
  private func disposeAudioSession() {
    try? persistentAudio?.setActive(false, options: [])
    persistentAudio = nil
  }

  private func setupBackgroundTasks() {

    MessageFetchBackgroundTaskOperator.register()

    if Settings.messageNotification {
      MessageFetchBackgroundTaskOperator.scheduleAppRefresh(timeInterval: TimeInterval(Settings.messageCheckInterval))

    } else {
      MessageFetchBackgroundTaskOperator.cancelAppRefresh()
    }

  }
  
}

extension AppDelegate: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {

    defer {
      completionHandler()
    }

    if response.notification.request.identifier == "UnreadAlert" {

      guard Keychain.shared.preferredUsername != nil else { return }

      queuedInbox.accept(true)

    }

    if response.notification.request.identifier == "Reminder" {

      guard
        let urlString = response.notification.request.content.userInfo["url"] as? String,
        let url = URL(string: urlString) else {
          return
      }

      queuedURL.accept(url)
    }
  }

}
