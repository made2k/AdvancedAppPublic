//
//  Rx+ASImageNode.swift
//  Reddit
//
//  Created by made2k on 4/5/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxCocoa_Texture
import RxSwift

extension Reactive where Base: ASImageNode {

  var imageTintColor: ASBinder<UIColor?> {

    return ASBinder(base) { node, color in
      node.tintColor = color
    }

  }

}
