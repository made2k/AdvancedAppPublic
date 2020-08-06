//
//  PlainThemeTableView.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

// TODO: Delete this
class PlainThemeTableView: UITableView {
  
  override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    backgroundColor = .systemBackground
    separatorColor = .separator
  }
  
}
