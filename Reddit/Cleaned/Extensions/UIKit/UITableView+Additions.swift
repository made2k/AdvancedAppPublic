//
//  UITableView+Additions.swift
//  Reddit
//
//  Created by made2k on 9/7/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

extension UITableView {

  func hideEmptyCells() {
    
    guard tableFooterView == nil else { return }
    
    tableFooterView = UIView()
  }
  
}

extension UITableView.Style {

  static var safeInsetGrouped: UITableView.Style {

    if #available(iOS 13.0, *) {
      return .insetGrouped

    } else {
      return .grouped
    }
  }

}
