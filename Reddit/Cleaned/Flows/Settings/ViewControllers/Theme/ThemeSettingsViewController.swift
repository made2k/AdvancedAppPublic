//
//  ThemeSettingsViewController.swift
//  Reddit
//
//  Created by made2k on 11/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Eureka

class ThemeSettingsViewController: SettingsBaseViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.settings.themeTitle()
    
    setupForm(form)
  }

}
