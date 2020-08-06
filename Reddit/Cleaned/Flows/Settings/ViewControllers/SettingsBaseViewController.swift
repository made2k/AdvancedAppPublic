//
//  SettingsBaseViewController.swift
//  Reddit
//
//  Created by made2k on 11/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Eureka

class SettingsBaseViewController: FormViewController {

  init() {

    // If settings are ever in detail, this could be good
    // super.init(style: .insetGrouped)
    super.init(style: .grouped)

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = .systemGroupedBackground
    tableView.separatorColor = .separator
  }

}
