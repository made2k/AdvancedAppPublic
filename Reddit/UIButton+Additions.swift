//
//  UIButton+Additions.swift
//  Reddit
//
//  Created by made2k on 1/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

typealias UIButtonTargetClosure = Action

class ClosureWrapper: NSObject {

  let closure: UIButtonTargetClosure

  init(_ closure: @escaping UIButtonTargetClosure) {
    self.closure = closure
  }

}

extension UIButton {

  private struct AssociatedKeys {
    static var targetClosure: UInt8 = 0
  }

  private var targetClosure: UIButtonTargetClosure? {
    get {
      guard let closureWrapper = objc_getAssociatedObject(self,
                                                          &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }

      return closureWrapper.closure
    }
    set(newValue) {
      guard let newValue = newValue else { return }
      objc_setAssociatedObject(self,
                               &AssociatedKeys.targetClosure,
                               ClosureWrapper(newValue),
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  // https://medium.com/@jackywangdeveloper/swift-the-right-way-to-add-target-in-uibutton-in-using-closures-877557ed9455
  func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
    targetClosure = closure
    addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
  }

  @objc private func closureAction() {

    guard let targetClosure = targetClosure else { return }

    targetClosure()
  }
}

