//
//  SplitCoordinator+Heirarchy.swift
//  Reddit
//
//  Created by made2k on 6/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SideMenu
import UIKit

extension SplitCoordinator {

  var topViewController: UIViewController {

    var viewController: UIViewController = splitViewController
    var presented: UIViewController? = viewController.presentedViewController

    while
      presented != nil &&
        (presented is SideMenuNavigationController ) == false &&
        (presented is SideMenuViewController) == false {

      guard let currentPresented = presented else {
        return viewController
      }

      viewController = currentPresented
      presented = viewController.presentedViewController

    }

    return viewController

  }

  var visibleListingController: ListingsViewController? {

    let base = topViewController

    let navigation: UINavigationController?

    if let navigationCast = base as? UINavigationController {
      navigation = navigationCast

    } else if let splitController = base as? UISplitViewController {

      if splitController.isCollapsed {
        navigation = splitController.viewControllers.last as? UINavigationController

      } else {
        navigation = splitController.viewControllers.first as? UINavigationController
      }

    } else {
      navigation = nil
    }

    if navigation == nil {
      return base as? ListingsViewController
    }

    return navigation?.viewControllers.last as? ListingsViewController
  }

  var visibleLinkController: LinkViewController? {

    let base = topViewController

    let navigation: UINavigationController?

    if let navigationCast = base as? UINavigationController {
      navigation = navigationCast

    } else if let splitController = base as? UISplitViewController {
      navigation = splitController.viewControllers.last as? UINavigationController

    } else {
      navigation = nil
    }

    if navigation == nil {
      return base as? LinkViewController
    }

    return navigation?.viewControllers.last as? LinkViewController
  }

}
