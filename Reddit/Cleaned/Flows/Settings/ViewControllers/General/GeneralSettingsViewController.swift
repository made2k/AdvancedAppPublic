//
//  GeneralSettingsViewController.swift
//  Reddit
//
//  Created by made2k on 11/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import Eureka
import UserNotifications

final class GeneralSettingsViewController: SettingsBaseViewController {

  struct Identifiers {
    static let notificationsRow = UUID().uuidString
    static let swipeEnabledRow = UUID().uuidString
    static let autoplayGifsRow = UUID().uuidString
  }

  let delegate: GeneralSettingsViewControllerDelegate

  init(delegate: GeneralSettingsViewControllerDelegate) {
    self.delegate = delegate

    super.init()

    title = R.string.settings.generalTitle()
    hideBackButtonTitle()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupForm(form)
  }
  
}
