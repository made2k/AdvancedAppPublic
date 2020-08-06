//
//  RedditSafariViewController.swift
//  Reddit
//
//  Created by made2k on 8/13/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import SafariServices
import SideMenu

class RedditSafariViewController: SFSafariViewController {

  override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    guard !(viewControllerToPresent is SideMenuNavigationController) else { return }
    super.present(viewControllerToPresent, animated: flag, completion: completion)
  }

}
