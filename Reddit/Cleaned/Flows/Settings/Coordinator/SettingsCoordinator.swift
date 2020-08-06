//
//  SettingsCoordinator.swift
//  Reddit
//
//  Created by made2k on 5/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

final class SettingsCoordinator: NSObject, Coordinator {

  private(set) weak var navigation: UINavigationController?
  private(set) weak var controller: SettingsViewController?

  var childCoordinator: Coordinator?

  init(navigation: UINavigationController) {
    self.navigation = navigation
  }

  func start() {
    let settings = SettingsViewController(delegate: self)
    self.controller = settings
    navigation?.pushViewController(settings)
  }

}
