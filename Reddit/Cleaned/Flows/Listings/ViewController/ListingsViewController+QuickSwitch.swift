//
//  ListingsViewController+QuickSwitch.swift
//  Reddit
//
//  Created by made2k on 1/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension ListingsViewController {

  func configureQuickSwitch() {
    let gesture = UITapGestureRecognizer(target: self,
                                         action: #selector(showQuickSwitch))

    navigationTitleView.addGestureRecognizer(gesture)
  }

  @objc private func showQuickSwitch() {
    if let navigation = navigationController {
      delegate?.didInitiateQuickSwitch(from: navigation)
    }
  }

}
