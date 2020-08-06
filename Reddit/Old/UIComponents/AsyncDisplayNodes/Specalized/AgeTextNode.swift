//
//  AgeTextNode.swift
//  Reddit
//
//  Created by made2k on 2/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class AgeTextNode: ImageTextNode {
  
  init(createdInterval: TimeInterval) {
    super.init(image: R.image.icon_time().unsafelyUnwrapped, textColor: .secondaryLabel)
    setText(StringUtils.timeAgoSince(createdInterval))
  }

}
