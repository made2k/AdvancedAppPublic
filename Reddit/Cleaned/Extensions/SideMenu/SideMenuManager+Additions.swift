//
//  SideMenuManager+Additions.swift
//  Reddit
//
//  Created by made2k on 2/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SideMenu
import UIKit

extension SideMenuManager {

  private struct AssociatedKeys {
    static var addedGestures: UInt8 = 0
  }

  private var presentingGestures: NSHashTable<UIGestureRecognizer> {
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.addedGestures, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    get {

      if let existing = objc_getAssociatedObject(self, &AssociatedKeys.addedGestures) as? NSHashTable<UIGestureRecognizer> {
        return existing
      }

      let new = NSHashTable<UIGestureRecognizer>.weakObjects()
      objc_setAssociatedObject(self, &AssociatedKeys.addedGestures, new, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

      return new
    }
  }

  /// Returns true if a gesture is currently active
  var isSlidePresenting: Bool {
    return presentingGestures
      .allObjects
      .contains(where: { $0.state == .began || $0.state == .changed })
  }

  var isActive: Bool {
    let splitview = SplitCoordinator.current.splitViewController
    return splitview.presentedViewController as? SideMenuNavigationController != nil
  }

  func addAndPersistGesture(to view: UIView, for menu: SideMenuManager.PresentDirection) {
    let recognizer = addScreenEdgePanGesturesToPresent(toView: view, forMenu: menu)
    presentingGestures.add(recognizer)
  }

  func dismiss(completion: (() -> Void)?) {

    let splitview = SplitCoordinator.current.splitViewController
    guard let sideMenu = splitview.presentedViewController as? SideMenuNavigationController else {
      completion?()
      return
    }

    sideMenu.dismiss(animated: true, completion: completion)
  }
}

