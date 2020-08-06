//
//  SideNavigationController.swift
//  Reddit
//
//  Created by made2k on 2/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SideMenu
import UIKit

class SideNavigationController: SideMenuNavigationController {

  // Basically a tracker for the view controller that would show by default
  // Ie the root view controller. Used when we swap out the displayed
  // controller dyanmically.
  private var desiredController: UIViewController?
  private var hasEndedDisplay = true

  init(rootViewController: UIViewController) {
    var settings = SideMenuSettings()
    settings.statusBarEndAlpha = 0

    super.init(rootViewController: rootViewController, settings: settings)

    self.desiredController = rootViewController
    commonInit()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    commonInit()
  }

  private func commonInit() {
    navigationBar.barTintColor = R.color.background()
    navigationBar.titleTextAttributes = [
      .foregroundColor: UIColor.systemGray3,
      .font: Settings.fontSettings.fontValue.semibold
    ]
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
    if #available(iOS 13.0, *) {

      return UITraitCollection(traitsFrom: [
        UITraitCollection(userInterfaceLevel: .elevated)
      ])

    } else {
      return super.overrideTraitCollection(forChild: childViewController)
    }
  }

  /*
   We have to dynamically figure out what view to show here. Rules as follows:
   - By default show the side menu (which is the root view of this controller)
   - If users settings to quick show side bar enable
   - AND
   - User is sliding out (not tapping)
   - Then show the side bar view controller.
 */
  override func viewWillAppear(_ animated: Bool) {

    if desiredController == nil, let rootViewController = viewControllers.first {
      desiredController = rootViewController
    }

    super.viewWillAppear(animated)

    guard let desiredController = desiredController, hasEndedDisplay else {
      visibleViewController?.viewWillAppear(animated)
      return
    }

    hasEndedDisplay = false

    if sideMenuManager.isSlidePresenting && Settings.slideOutSideBar {

      var sideBar: SideBarViewController?

      if
        let model = (SplitCoordinator.current.visibleListingController?.delegate as? ListingsCoordinator)?.listingDisplay as? SubredditModel,
        model.isUserSubreddit == false {
        
        sideBar = SideBarViewController(model: model)
        
      } else if
        let subredditName = SplitCoordinator.current.visibleLinkController?.model?.link.subreddit,
        UserSubreddit.fromPath(subredditName) == nil {
        
        sideBar = SideBarViewController(subredditName: subredditName)
      }

      if let sideBar = sideBar {
        viewControllers = [sideBar]
      } else {
        viewControllers = [desiredController]
      }

    } else {
      viewControllers = [desiredController]
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    // Don't let super call the will appear hack
    hasEndedDisplay = true
  }
}
