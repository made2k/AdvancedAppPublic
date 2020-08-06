//
//  UIRefreshControl+Closures.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//

import UIKit

extension UIRefreshControl {

  private struct AssociatedKeys {
    static var action: UInt8 = 0
  }

  var action: ((UIRefreshControl) -> Void)? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.action) as? (UIRefreshControl) -> Void }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.action, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      addTarget(self, action: #selector(doAction(_:)), for: .valueChanged)
    }
  }

  @objc private func doAction(_ control: UIRefreshControl) {
    action?(control)
  }

  convenience init(handler: @escaping (UIRefreshControl) -> Void) {
    self.init()
    action = handler
  }

}
