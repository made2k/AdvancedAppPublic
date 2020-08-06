//
//  Rx+DTCoreTextNode.swift
//  Reddit
//
//  Created by made2k on 6/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxCocoa_Texture
import RxSwift

extension Reactive where Base: DTCoreTextNode {

  var html: ASBinder<String?> {
    return ASBinder(base) { node, html in
      node.html = html
    }
  }

}
