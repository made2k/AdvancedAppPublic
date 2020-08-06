//
//  ASLayoutSpec+Additions.swift
//  Reddit
//
//  Created by made2k on 11/12/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ASLayoutSpec {
  
  static func spacer() -> ASLayoutSpec {

    let spacer = ASLayoutSpec()

    spacer.style.flexGrow = 1

    return spacer
  }
  
}
