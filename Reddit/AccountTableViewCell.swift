//
//  AccountTableViewCell.swift
//  Reddit
//
//  Created by made2k on 3/15/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

class AccountTableViewCell: GroupThemeTableViewCell {
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var selectedImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    selectedImageView.tintColor = .label
  }

}
