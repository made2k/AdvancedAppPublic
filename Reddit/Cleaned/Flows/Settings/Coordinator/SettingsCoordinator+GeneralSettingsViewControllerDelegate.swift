//
//  SettingsCoordinator+GeneralSettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka
import Foundation
import RedditAPI
import UserNotifications

extension SettingsCoordinator: GeneralSettingsViewControllerDelegate {

  var hasNotificationAccess: Bool {

    let semaphore = DispatchSemaphore(value: 0)

    var value = false

    UNUserNotificationCenter.current().getNotificationSettings { settings in
      value = settings.authorizationStatus != .denied
      semaphore.signal()
    }

    semaphore.wait()

    return value
  }

  func didSelectDefaultPostSort(updating row: LabelRow) {
    let alert = AlertController()

    for sortType in [LinkSortType.hot, .new, .rising, .controversial] {

      let sortAction = AlertAction(title: sortType.rawValue, icon: sortType.icon) {
        Settings.defaultPostSort = sortType

        row.value = sortType.rawValue
        row.reload()
      }

      alert.addAction(sortAction)
    }

    alert.show()
  }

  func didSelectOpenLinksIn() {
    let controller = OpenInTableViewController()
    navigation?.pushViewController(controller)
  }

  func didSelectDefaultCommentSort(updating row: LabelRow) {
    let alert = AlertController()

    for sortType in [CommentSort.confidence, .hot, .new, .controversial, .old, .top] {

      let sortAction = AlertAction(title: sortType.rawValue, icon: sortType.icon) {
        Settings.defaultCommentSort = sortType

        row.value = sortType.rawValue
        row.reload()
      }

      alert.addAction(sortAction)
    }

    alert.show()
  }

  func didSelectNumberOfComments(updating row: LabelRow) {
    let alert = AlertController()

    for count in [50, 100, 200, 300, 400, 500] {

      let action = AlertAction(title: count.description, icon: nil) {
        Settings.numberOfCommentsToLoad = count

        row.value = count.description
        row.reload()
      }

      alert.addAction(action)
    }

    alert.show()
  }

  func didSelectNavigationPosition(updating row: LabelRow) {
    let alert = AlertController()

    for side in [Side.left, .center, .right, .none] {

      let action = AlertAction(title: side.rawValue, icon: nil) {
        Settings.commentNavigatorPosition = side

        row.value = side.rawValue
        row.reload()
      }

      alert.addAction(action)
    }

    alert.show()
  }

  func didSelectLiveComments() {
    let controller = LiveCommentsSettingsViewController(delegate: self)
    navigation?.pushViewController(controller)
  }

  func didSelectSwipeConfiguration() {
    let controller = R.storyboard.swipeConfiguration.swipeList().unsafelyUnwrapped
    navigation?.pushViewController(controller)
  }

  func attemptToEnableNotifications(updating row: SwitchRow) {

    let alertOptions: UNAuthorizationOptions = [.alert, .sound]

    UNUserNotificationCenter.current().requestAuthorization(options: alertOptions) { granted, _ in

      if granted {
        Settings.messageNotification = true

      } else {
        DispatchQueue.main.async { [weak self] in
          row.value = false
          row.updateCell()
          self?.showNotificationPermissionAlert()
        }
      }

    }

  }

  private func showNotificationPermissionAlert() {
    let alert = UIAlertController(title: R.string.settings.messagePermissionTitle(),
                                  message: R.string.settings.messagePermissionDetail(),
                                  preferredStyle: .alert)

    alert.addAction(title: R.string.settings.settingsAction()) { _ in
      UIApplication.openApplicationSettings()
    }
    alert.addAction(title: R.string.settings.okayAction())

    navigation?.present(alert)
  }

  func didSelectMessageFetchInterval(updating row: LabelRow) {
    let alert = AlertController()

    for interval in [5, 15, 30, 60] {

      let description = R.string.settings.intervalTiming(interval)

      let action = AlertAction(
        title: description,
        icon: R.image.iconTimer()) {
          Settings.messageCheckInterval = interval * 60
          row.value = description
          row.updateCell()
      }
      alert.addAction(action)

    }

    let manualAction = AlertAction(title: R.string.settings.manualInterval(), icon: R.image.icon_manual_refresh()) {
      Settings.messageCheckInterval = Int.max
      row.value = R.string.settings.manualInterval()
      row.updateCell()
    }
    alert.addAction(manualAction)

    alert.show()
  }
  
  func didSelectVolumePosition(updating row: LabelRow) {
    
    let alert = AlertController()
    
    for position in CornerPosition.allCases {
      
      let action = AlertAction(title: position.description, icon: position.icon) {
        Settings.volumePosition.accept(position)
        row.value = position.description
        row.updateCell()
      }
      alert.addAction(action)
      
    }
    
    alert.show()
    
  }

  func didSelectStartOnSubreddit(updating row: LabelRow) {

    guard let navigation = navigation else { return }

    let selectionAction: LoadableSelection = { model in
      Settings.startOnSubreddit = model.queryable
      SplitCoordinator.current.resetStartingSubreddit(model)
      row.value = model.title

      navigation.popViewController()
    }

    let coordinator = SubredditListCoordinator(navigation: navigation,
                                               tableStyle: .grouped,
                                               customAction: selectionAction)
    coordinator.start()
  }

  func didSelectConfigureCache() {
    let controller = CacheSizeTableViewController.create()
    navigation?.pushViewController(controller)
  }

}
