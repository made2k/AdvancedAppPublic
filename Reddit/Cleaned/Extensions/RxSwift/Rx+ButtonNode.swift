//
//  Rx+ButtonNode.swift
//  Reddit
//
//  Created by made2k on 5/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxCocoa_Texture
import RxSwift

extension Reactive where Base: ButtonNode {
  
  var title: ASBinder<String?> {
    return ASBinder(base) { button, title in
      button.title = title
    }
  }

  var tintColor: ASBinder<UIColor?> {
    return ASBinder(base) { button, color in
      button.tintColor = color
    }
  }

}
