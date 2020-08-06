//
//  Rx+TextNode.swift
//  Reddit
//
//  Created by made2k on 5/27/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa_Texture
import RxSwift

extension Reactive where Base: TextNode {

  var text: ASBinder<String?> {
    return ASBinder(self.base) { node, text in
      node.text = text
    }
  }
  
  var font: ASBinder<UIFont> {
    return ASBinder(self.base) { node, font in
      node.font = font
    }
  }

  var textColor: ASBinder<UIColor> {
    return ASBinder(self.base) { node, textColor in
      node.textColor = textColor
    }
  }

}
