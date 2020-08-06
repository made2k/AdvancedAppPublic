//
//  UIViewController+Presentable.swift
//  Reddit
//
//  Created by made2k on 2/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func display(_ viewController: UIViewController) {

    switch UIViewController.displayStyle(for: viewController) {
    case .modal:
      present(viewController)

    case .primary:
      show(viewController, sender: self)

    case .detail:
      let vc: UINavigationController
      if let nav = viewController as? UINavigationController {
        vc = nav
      } else {
        vc = NavigationController(controllers: viewController)
      }
      showDetailViewController(vc, sender: self)

    case .none:
      break
    }

  }
  
  static func displayStyle(for viewController: UIViewController) -> PresentingType {

    guard let presentable = viewController.topViewController() as? Presentable else {
      return .modal
    }
    
    return presentable.presentingType
  }
  
}
