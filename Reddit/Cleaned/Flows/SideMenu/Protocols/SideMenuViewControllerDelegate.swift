//
//  SideMenuViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

protocol SideMenuViewControllerDelegate: class {

  func dismissAndShow(_ controller: UIViewController)
  func dismissAndPresent(_ controller: UIViewController)
  func dismiss(completion: @escaping () -> Void)

  func dismissAndShowSettings()
  func dismissAndShowSubredditList()
  func dismissAndShowSearch()
}
