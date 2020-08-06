//
//  SplitCoordinator+ListingsCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 1/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension SplitCoordinator: ListingsCoordinatorDelegate {

  func didOpenLink(_ model: LinkModel) {

    let navigation = NavigationController()

    let coordinator = LinkCoordinator(model: model, navigation: navigation)
    coordinator.start()

    splitViewController.showDetailViewController(navigation, sender: self)

  }

}

