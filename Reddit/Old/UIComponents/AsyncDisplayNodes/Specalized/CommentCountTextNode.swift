//
//  CommentCountTextNode.swift
//  Reddit
//
//  Created by made2k on 2/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class CommentCountTextNode: ImageTextNode {
  
  init(commentCount: Int) {
    super.init(image: R.image.icon_comment().unsafelyUnwrapped, textColor: .secondaryLabel)
    setText(StringUtils.numberSuffix(commentCount, min: 1000))
  }

}
