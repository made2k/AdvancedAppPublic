//
//  AppearanceSettingsViewController.swift
//  Reddit
//
//  Created by made2k on 11/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import Eureka

class AppearanceSettingsViewController: SettingsBaseViewController {
  
  struct Identifiers {
    static let preventSplitView = UUID().uuidString
    static let hideThumbnails = UUID().uuidString
    static let showLinkFlair = UUID().uuidString
    static let showCommentFlair = UUID().uuidString
  }
  
  private(set) weak var delegate: AppearanceSettingsViewControllerDelegate?
  
  init(delegate: AppearanceSettingsViewControllerDelegate) {
    self.delegate = delegate
    
    super.init()
    
    title = R.string.settings.appearanceTitle()
    hideBackButtonTitle()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupForm(form)
  }
  
  // TODO: Evaluate if these are needed
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  // TODO: If this not needed, delete app icon tag here and in form setup
  func updateIconCell() {
    if let row = form.rowBy(tag: "AppIcon") as? IconRow {
      if let name = UIApplication.shared.alternateIconName {
        let image = UIImage(named: name)
        row.cell.icon.image = image
      } else {
        row.cell.icon.image = UIImage.appIcon
      }
    }
  }
  
}
