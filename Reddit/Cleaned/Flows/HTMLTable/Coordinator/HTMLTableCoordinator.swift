//
//  HTMLTableCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

final class HTMLTableCoordinator: NSObject, Coordinator {

  private let navigation: UINavigationController

  private let tableData: String
  private(set) weak var controller: HTMLTableViewController?

  init(navigation: UINavigationController, tableData: String) {
    self.navigation = navigation
    self.tableData = tableData
  }

  func start() {

    let maxRowWidth = max(200, navigation.view.frame.width * 2 / 3)
    let tableStackView = HTMLTableBuilder(tableString: tableData,
                                          maxRowSize: maxRowWidth,
                                          delegate: self).build()

    let controller = HTMLTableViewController(tableStackView: tableStackView, delegate: self)
    self.controller = controller

    let isAnimated = navigation.viewControllers.isNotEmpty
    navigation.pushViewController(controller, animated: isAnimated)
  }
  
}
