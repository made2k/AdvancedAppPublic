//
//  ThemeableEditableTextNode.swift
//  Reddit
//
//  Created by made2k on 6/5/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ThemeableEditableTextNode: EditableTextNode {

  init(textColor: UIColor, backgroundColor: UIColor) {
    super.init()

    self.textColor = textColor
    self.backgroundColor = backgroundColor

    textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
  }

  override init(textKitComponents: ASTextKitComponents, placeholderTextKitComponents: ASTextKitComponents) {
    super.init(textKitComponents: textKitComponents, placeholderTextKitComponents: placeholderTextKitComponents)
  }

}
