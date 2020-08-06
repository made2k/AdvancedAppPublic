//
//  Rx+ASDisplayNode.swift
//  Reddit
//
//  Created by made2k on 2/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxCocoa_Texture
import RxSwift

extension Reactive where Base: ASDisplayNode {

  var alpha: ASBinder<CGFloat> {
    return ASBinder(base) { node, alpha in
      node.alpha = alpha
    }
  }

  var backgroundColor: ASBinder<UIColor?> {
    return ASBinder(base) { node, color in
      node.backgroundColor = color
    }
  }

}
