//
//  RoundedTextNode.swift
//  Reddit
//
//  Created by made2k on 5/27/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class RoundedTextNode: TextNode {

  override func layoutDidFinish() {
    super.layoutDidFinish()

    cornerRadius = min(bounds.width, bounds.height) / 2
  }

}
