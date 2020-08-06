//
//  SecondaryLabel.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class SecondaryLabel: UILabel {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    textColor = .secondaryLabel
  }
  
}
