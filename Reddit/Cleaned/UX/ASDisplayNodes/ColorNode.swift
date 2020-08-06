//
//  ColorNode.swift
//  Reddit
//
//  Created by made2k on 2/20/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import AsyncDisplayKit

// TODO: Delete this, no longer needed after ios 13 change
class ColorNode: ASDisplayNode {

  init(backgroundColor: UIColor) {
    super.init()
    self.backgroundColor = backgroundColor
  }

}

class ColorControlNode: ASControlNode {

  init(backgroundColor: UIColor) {
    super.init()
    self.backgroundColor = backgroundColor
  }

}
