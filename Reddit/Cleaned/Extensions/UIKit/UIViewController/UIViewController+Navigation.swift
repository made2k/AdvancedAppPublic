//
//  UIViewController+Navigation.swift
//  Reddit
//
//  Created by made2k on 5/31/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension UIViewController {
  
  // MARK: - Presentation
  
  func dismiss() {
    dismiss(animated: true, completion: nil)
  }
  
  func present(_ viewControllerToPresent: UIViewController) {
    present(viewControllerToPresent, animated: true, completion: nil)
  }
  
  // MARK: - Child Controllers
  
  func addChildController(_ child: UIViewController, view: UIView) {
    self.addChild(child)
    child.view.frame = view.bounds
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }
  
  func removeChildController(_ child: UIViewController?) {
    child?.willMove(toParent: nil)
    child?.view.removeFromSuperview()
    child?.removeFromParent()
  }
  
  // MARK: - Navigation
  
  func hideBackButtonTitle() {
    let button = UIBarButtonItem()
    button.title = ""
    navigationItem.backBarButtonItem = button
  }
  
  func topViewController() -> UIViewController {
    
    if let navigation = self as? UINavigationController {
      return navigation.viewControllers.last ?? self
    }
    
    return self
  }
  
}
