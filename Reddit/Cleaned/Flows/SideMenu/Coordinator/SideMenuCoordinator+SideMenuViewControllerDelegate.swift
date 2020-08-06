//
//  SideMenuCoordinator+SideMenuViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension SideMenuCoordinator: SideMenuViewControllerDelegate {

  func dismissAndShow(_ controller: UIViewController) {
    sideNavigation.dismiss(animated: true) {
      SplitCoordinator.current.splitViewController.show(controller, sender: self)
    }
  }

  func dismissAndPresent(_ controller: UIViewController) {
    sideNavigation.dismiss(animated: true) {
      SplitCoordinator.current.splitViewController.present(controller)
    }
  }

  func dismiss(completion: @escaping () -> Void) {
    sideNavigation.dismiss(animated: true, completion: completion)
  }

  func dismissAndShowSettings() {
    let navigation = SplitCoordinator.current.masterNavigation
    let coordinator = SettingsCoordinator(navigation: navigation)

    sideNavigation.dismiss(animated: true) {
      coordinator.start()
    }
  }

  func dismissAndShowSubredditList() {

    let navigation = SplitCoordinator.current.masterNavigation
    let coordinator = SubredditListCoordinator(navigation: navigation, tableStyle: .grouped)

    sideNavigation.dismiss(animated: true) {
      coordinator.start()
    }

  }

  func dismissAndShowSearch() {

    let navigation = SplitCoordinator.current.masterNavigation
    let coordinator = SearchCoordinator(navigation: navigation)

    sideNavigation.dismiss(animated: true) {
      coordinator.start()
    }

  }

}
