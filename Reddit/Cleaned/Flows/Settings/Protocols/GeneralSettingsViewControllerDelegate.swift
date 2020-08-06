//
//  GeneralSettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

protocol GeneralSettingsViewControllerDelegate: class {

  var hasNotificationAccess: Bool { get }

  func didSelectDefaultPostSort(updating row: LabelRow)
  func didSelectOpenLinksIn()
  func didSelectDefaultCommentSort(updating row: LabelRow)
  func didSelectNumberOfComments(updating row: LabelRow)
  func didSelectNavigationPosition(updating row: LabelRow)
  func didSelectLiveComments()
  func didSelectSwipeConfiguration()
  func attemptToEnableNotifications(updating row: SwitchRow)
  func didSelectMessageFetchInterval(updating: LabelRow)
  
  func didSelectVolumePosition(updating: LabelRow)

  func didSelectStartOnSubreddit(updating: LabelRow)
  func didSelectConfigureCache()

}
