//
//  VisualEffectNode.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import UIKit

class VisualEffectNode: ASDisplayNode {

  private var visualEffectView: UIVisualEffectView!

  var contentView: UIView {
    return visualEffectView.contentView
  }

  init(effect: UIVisualEffect) {
    super.init()

    setViewBlock { [weak self] () -> UIView in
      let effectView = UIVisualEffectView(effect: effect)
      self?.visualEffectView = effectView
      return effectView
    }
  }

}
