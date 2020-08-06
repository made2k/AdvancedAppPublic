//
//  ASControlNode+Additions.swift
//  Reddit
//
//  Created by made2k on 12/31/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ASControlNode {
  
  struct AssociatedKeys {
    static var tapAction: UInt8 = 0
  }

  // TODO: Replace with what's in UIButton or move all to rx.tap
  var tapAction: (() -> Void)? {
    get {
      guard let value = objc_getAssociatedObject(self, &AssociatedKeys.tapAction) as? (() -> Void) else { return nil }
      return value
    }
    set(newValue) {
      objc_setAssociatedObject(self, &AssociatedKeys.tapAction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      addTarget(self, action: #selector(wasTapped), forControlEvents: .touchUpInside)
    }
  }
  
  @objc private func wasTapped() {
    tapAction?()
  }
}
