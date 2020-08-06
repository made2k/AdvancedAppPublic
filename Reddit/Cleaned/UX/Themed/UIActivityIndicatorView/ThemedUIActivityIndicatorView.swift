//
//  ThemedUIActivityIndicatorView.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class ThemedUIActivityIndicatorView: UIActivityIndicatorView {
  
  override init(style: UIActivityIndicatorView.Style) {
    super.init(style: style)
    commonInit()
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    style = .medium
  }
  
}

