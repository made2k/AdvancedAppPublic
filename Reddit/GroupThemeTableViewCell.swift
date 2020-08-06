//
//  GroupThemeTableViewCell.swift
//  Reddit
//
//  Created by made2k on 1/13/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class GroupThemeTableViewCell: UITableViewCell {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    commonInit()
  }
  
  func commonInit() {
    let selectedview = SelectedCellBackgroundView()
    selectedBackgroundView = selectedview
    backgroundColor = .secondarySystemGroupedBackground
  }

}

