//
//  SelectedCellBackgroundView.swift
//  Reddit
//
//  Created by made2k on 9/15/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class SelectedCellBackgroundView: UIView {

  init() {
    super.init(frame: .zero)
    backgroundColor = R.color.selectedRowColor()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
