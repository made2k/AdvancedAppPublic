//
//  NavigationController.swift
//  Reddit
//
//  Created by made2k on 1/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

/**
 This class defaults to a themed navigation bar and also
 will pass on any calls to preview action items to it's
 child view controllers if they exist.
 */
class NavigationController: UINavigationController {

  init() {
    super.init(navigationBarClass: ThemedNavigationBar.self, toolbarClass: nil)
  }
  
  convenience init(controllers: UIViewController...) {
    self.init()
    viewControllers = controllers
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
    
}
