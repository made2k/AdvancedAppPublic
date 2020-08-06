//
//  SplitViewCoordinator.swift
//  Reddit
//
//  Created by made2k on 9/26/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

// TODO: Test and cleanup this whole file
extension AppDelegate: UISplitViewControllerDelegate {
  
  func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
    
    if let navigation = primaryViewController as? UINavigationController {
      if let secondary = applyNavigationControllers(primary: navigation, secondary: nil) {
        return secondary
      }

      let navigation = UINavigationController()
      LinkCoordinator(navigation: navigation).start()
      return navigation

    }

     return nil
  }

  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    if let navigation = secondaryViewController as? UINavigationController {

      if let lastNav = navigation.viewControllers.last as? LinkViewController {
        return lastNav.link == nil
      }

      return navigation.viewControllers.isEmpty
    }
    return false
  }
  
  func applyNavigationControllers(primary: UINavigationController, secondary: UINavigationController?) -> UINavigationController? {
    
    var secondary = secondary
    
    // First we move any listing controllers from the secondary and place them in the primary
    if let secondary = secondary {
      for (index, child) in secondary.viewControllers.enumerated() where child is ListingsViewController {
        let listing = secondary.viewControllers.remove(at: index)
        primary.viewControllers.append(listing)
      }
    }
    
    // Then we continue through primary to make sure
    for (index, child) in primary.viewControllers.enumerated() {
      
      if let child = child as? UINavigationController {
        secondary?.viewControllers.append(contentsOf: child.viewControllers)
        primary.viewControllers.remove(at: index)
        // Get rid of the secondary stuff here to go back to only showing one
        return applyNavigationControllers(primary: primary, secondary: secondary ?? child)
        
      } else if let link = child as? LinkViewController {
        secondary = secondary ?? UINavigationController()
        
        // If one of the view controllers is a link, that should be shown in secondary
        primary.viewControllers.remove(at: index)
        secondary?.viewControllers.append(link)
      }
    }
    
    return secondary
  }
  
}
