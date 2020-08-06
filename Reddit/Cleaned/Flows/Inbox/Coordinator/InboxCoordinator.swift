//
//  InboxCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/4/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import UIKit

final class InboxCoordinator: NSObject, Coordinator {

  let navigation: UINavigationController
  private(set) weak var controller: InboxViewController?
  let model: InboxModel = InboxModel()

  var childCoordinator: Coordinator?

  init(navigation: UINavigationController) {
    self.navigation = navigation
  }

  convenience init(split: SplitCoordinator) {
    let navigation: UINavigationController = split.masterNavigation
    self.init(navigation: navigation)
  }

  func start() {
    let controller: InboxViewController = InboxViewController(model: model, strongDelegate: self)
    navigation.pushViewController(controller)

    self.controller = controller
  }

}
