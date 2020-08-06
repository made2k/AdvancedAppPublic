//
//  ScoreTextNode.swift
//  Reddit
//
//  Created by made2k on 2/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ScoreTextNode: ImageTextNode {
  
  init(score: Int, weight: FontWeight = .regular, size: FontSize = .default, textColor: UIColor = .secondaryLabel) {
    super.init(image: R.image.icon_upvote().unsafelyUnwrapped, textColor: textColor)
    setText(StringUtils.numberSuffix(score, min: 1000))
  }
}
